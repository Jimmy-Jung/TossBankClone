import XCTest
@testable import NetworkModule

class RetryPluginTests: XCTestCase {
    
    // MARK: - 테스트 대상
    private var sut: RetryPlugin!
    
    // MARK: - 셋업 및 테어다운
    override func setUp() {
        super.setUp()
        sut = RetryPlugin(configuration: RetryPlugin.Configuration(
            maxRetries: 3,
            baseDelay: 0.01, // 테스트를 빠르게 실행하기 위해 지연 시간 줄임
            delayMultiplier: 2.0,
            maxDelay: 0.1
        ))
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - 테스트
    func testSuccessfulResponseShouldNotRetry() async throws {
        // Given
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let data = Data()
        
        // When/Then
        // 성공 응답은 예외를 발생시키지 않아야 함
        try await sut.process(request, response, data)
    }
    
    func testRetryableErrorShouldRetryAndEventuallyFail() async {
        // Given
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let data = Data()
        
        // When/Then
        var retryCount = 0
        do {
            // 첫 번째 시도 + 재시도 3회 = 총 4회 시도
            for _ in 0...3 {
                do {
                    try await sut.process(request, response, data)
                    XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
                } catch let error as NetworkError {
                    if case .httpError(let statusCode, _) = error {
                        XCTAssertEqual(statusCode, 500)
                        retryCount += 1
                    } else {
                        XCTFail("예상된 오류 타입이 아닙니다: \(error)")
                    }
                }
            }
            // 최대 3회까지만 재시도 (구성에 따라)
            XCTAssertEqual(retryCount, 4)
        }
    }
    
    func testNonRetryableErrorShouldNotRetry() async {
        // Given
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
        let data = Data()
        
        // When/Then
        do {
            try await sut.process(request, response, data)
            XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
        } catch let error as NetworkError {
            if case .httpError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 401)
            } else {
                XCTFail("예상된 오류 타입이 아닙니다: \(error)")
            }
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
    
    func testCustomRetryConfig() async {
        // Given
        // 특정 상태 코드만 재시도하는 커스텀 설정
        let customRetry = RetryPlugin(configuration: .init(
            maxRetries: 2,
            baseDelay: 0.01,
            isRetryableError: { error in
                if let networkError = error as? NetworkError,
                   case .httpError(let statusCode, _) = networkError {
                    return statusCode == 503 // Service Unavailable만 재시도
                }
                return false
            }
        ))
        
        let request = URLRequest(url: URL(string: "https://example.com")!)
        
        // 503 응답은 재시도해야 함
        let unavailableResponse = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
        
        // 500 응답은 재시도하지 않아야 함
        let serverErrorResponse = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        let data = Data()
        
        // When/Then
        // 503 오류는 재시도되어야 함
        var retryCount = 0
        for _ in 0...2 {
            do {
                try await customRetry.process(request, unavailableResponse, data)
                XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
            } catch {
                retryCount += 1
            }
        }
        XCTAssertEqual(retryCount, 3) // 초기 요청 + 재시도 2회
        
        // 500 오류는 재시도되지 않아야 함
        do {
            try await customRetry.process(request, serverErrorResponse, data)
            XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
        } catch let error as NetworkError {
            if case .httpError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 500)
            } else {
                XCTFail("예상된 오류 타입이 아닙니다: \(error)")
            }
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
    
    func testExponentialBackoff() async {
        // Given
        // 지수 백오프 동작 확인을 위한 설정
        let backoffPlugin = RetryPlugin(configuration: .init(
            maxRetries: 3,
            baseDelay: 0.1,
            delayMultiplier: 2.0,
            maxDelay: 1.0
        ))
        
        let request = URLRequest(url: URL(string: "https://example.com")!)
        let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
        let data = Data()
        
        // When/Then
        let startTime = Date()
        
        // 첫 번째 재시도 (지연: 0.1초)
        do {
            try await backoffPlugin.process(request, response, data)
            XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
        } catch {
            let elapsedTime1 = Date().timeIntervalSince(startTime)
            XCTAssertGreaterThanOrEqual(elapsedTime1, 0.09) // 약간의 오차 허용
            
            // 두 번째 재시도 (지연: 0.2초)
            do {
                try await backoffPlugin.process(request, response, data)
                XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
            } catch {
                let elapsedTime2 = Date().timeIntervalSince(startTime)
                XCTAssertGreaterThanOrEqual(elapsedTime2, 0.29) // 첫 번째 지연(0.1) + 두 번째 지연(0.2) = 0.3
                
                // 세 번째 재시도 (지연: 0.4초)
                do {
                    try await backoffPlugin.process(request, response, data)
                    XCTFail("재시도 플러그인이 성공을 반환해서는 안 됩니다")
                } catch {
                    let elapsedTime3 = Date().timeIntervalSince(startTime)
                    XCTAssertGreaterThanOrEqual(elapsedTime3, 0.69) // 총 지연 시간 0.1 + 0.2 + 0.4 = 0.7
                }
            }
        }
    }
} 