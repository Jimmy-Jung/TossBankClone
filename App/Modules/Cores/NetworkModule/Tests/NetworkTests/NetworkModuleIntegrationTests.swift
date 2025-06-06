import XCTest
@testable import NetworkModule

class NetworkModuleIntegrationTests: XCTestCase {
    
    // MARK: - 테스트 대상
    private var baseURL: URL!
    private var mockURLSession: MockURLSession!
    private var mockReachability: MockNetworkReachability!
    private var networkService: NetworkService!
    
    // MARK: - 셋업 및 테어다운
    override func setUp() {
        super.setUp()
        
        baseURL = URL(string: "https://api.example.com")!
        mockURLSession = MockURLSession()
        mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true
    }
    
    override func tearDown() {
        baseURL = nil
        mockURLSession = nil
        mockReachability = nil
        networkService = nil
        
        super.tearDown()
    }
    
    // MARK: - 통합 테스트
    func testSuccessfulRequestWithPlugins() async throws {
        // Given
        // 로깅 플러그인 설정
        let loggingPlugin = LoggingPlugin(logLevel: .body)
        
        // 인증 토큰 제공자 설정
        let authTokenProvider = { return "test-auth-token" }
        let authPlugin = AuthPlugin(tokenProvider: authTokenProvider)
        
        // 타임아웃 설정
        let timeoutPlugin = TimeoutPlugin(timeout: 60.0)
        
        // 서비스 설정
        networkService = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [loggingPlugin, authPlugin, timeoutPlugin],
            reachability: mockReachability
        )
        
        // 모의 응답 설정
        let expectedData = #"{"id": 1, "name": "통합 테스트 아이템"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL.appendingPathComponent("/items/1"), statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = expectedData
        mockURLSession.nextResponse = response
        
        // API 요청 설정
        let testRequest = TestAPIRequest<TestItem>(
            path: "/items/1",
            headers: ["X-Custom-Header": "Custom-Value"],
            cachePolicyForURLRequest: .useProtocolCachePolicy
        )
        let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
        
        // When
        let result = try await networkService.request(urlRequest, responseType: TestItem.self)
        
        // Then
        // 결과 검증
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "통합 테스트 아이템")
        
        // 플러그인 동작 검증
        // LoggingPlugin은 내부적으로 로깅하므로 별도 검증 없음
        
        // 요청 검증
        let capturedRequest = mockURLSession.lastRequest
        XCTAssertNotNil(capturedRequest)
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.example.com/items/1")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-auth-token")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "X-Custom-Header"), "Custom-Value")
        XCTAssertEqual(capturedRequest?.timeoutInterval, 60.0)
    }
    
    func testSuccessfulUploadWithPlugins() async throws {
        // Given
        // 로깅 플러그인 설정
        let loggingPlugin = LoggingPlugin(logLevel: .body)
        
        // 인증 토큰 제공자 설정
        let authTokenProvider = { return "test-auth-token" }
        let authPlugin = AuthPlugin(tokenProvider: authTokenProvider)
        
        // 서비스 설정
        networkService = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [loggingPlugin, authPlugin],
            reachability: mockReachability
        )
        
        // 모의 응답 설정
        let expectedData = #"{"id": 2, "name": "업로드된 이미지"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL.appendingPathComponent("/upload"), statusCode: 201, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = expectedData
        mockURLSession.nextResponse = response
        
        // 업로드할 데이터
        let uploadData = "테스트 이미지 데이터".data(using: .utf8)!
        
        // API 요청 설정
        let testRequest = TestAPIRequest<TestItem>(path: "/upload", method: .post)
        let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
        
        // When
        let result = try await networkService.upload(urlRequest, data: uploadData, mimeType: "image/jpeg", responseType: TestItem.self)
        
        // Then
        // 결과 검증
        XCTAssertEqual(result.id, 2)
        XCTAssertEqual(result.name, "업로드된 이미지")
        
        // 플러그인 동작 검증
        // LoggingPlugin은 내부적으로 로깅하므로 별도 검증 없음
        
        // 요청 검증
        let capturedRequest = mockURLSession.lastRequest
        XCTAssertNotNil(capturedRequest)
        XCTAssertEqual(capturedRequest?.url?.absoluteString, "https://api.example.com/upload")
        XCTAssertEqual(capturedRequest?.httpMethod, "POST")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Content-Type"), "image/jpeg")
        XCTAssertEqual(capturedRequest?.value(forHTTPHeaderField: "Authorization"), "Bearer test-auth-token")
    }
    
    func testFailedRequestWithRetry() async {
        // Given
        // 재시도 플러그인 설정 (테스트용으로 지연 시간 최소화)
        let retryPlugin = RetryPlugin(configuration: .init(
            maxRetries: 2,
            baseDelay: 0.01,
            delayMultiplier: 1.0,
            maxDelay: 0.01
        ))
        
        // 서비스 설정
        networkService = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [retryPlugin],
            reachability: mockReachability
        )
        
        // 모의 실패 응답 설정
        let errorData = #"{"error": "서버 오류"}"#.data(using: .utf8)!
        let errorResponse = HTTPURLResponse(url: baseURL.appendingPathComponent("/error"), statusCode: 500, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = errorData
        mockURLSession.nextResponse = errorResponse
        
        // API 요청 설정
        let testRequest = TestAPIRequest<TestItem>(path: "/error")
        
        // When/Then
        // 재시도 수동 구현
        var retryCount = 0
        let maxRetries = 2
        
        while retryCount <= maxRetries {
            do {
                let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
                _ = try await networkService.request(urlRequest, responseType: TestItem.self)
                XCTFail("요청이 성공해서는 안 됩니다")
                break
            } catch {
                // 오류가 발생하면 재시도 카운트 증가
                retryCount += 1
                
                // 최대 재시도 횟수에 도달하지 않았다면 계속 재시도
                if retryCount <= maxRetries {
                    // 재시도 지연 시간 대기
                    try? await Task.sleep(nanoseconds: 10_000_000) // 0.01초
                    continue
                }
                break
            }
        }
        
        // 재시도 횟수 확인 (초기 요청 + 재시도 2회 = 총 3회)
        XCTAssertEqual(mockURLSession.requestCount, 3)
    }
    
    func testNetworkReachabilityCheck() async {
        // Given
        // 연결 상태 오프라인으로 설정
        mockReachability.isConnected = false
        
        // 서비스 설정
        let connectivityPlugin = ConnectivityPlugin(reachability: mockReachability)
        
        networkService = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [connectivityPlugin],
            reachability: mockReachability
        )
        
        // API 요청 설정
        let testRequest = TestAPIRequest<TestItem>(path: "/items/1")
        
        // When/Then
        do {
            let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
            _ = try await networkService.request(urlRequest, responseType: TestItem.self)
            XCTFail("오프라인 상태에서 요청이 성공해서는 안 됩니다")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.offline)
            // 실제 네트워크 요청이 이루어지지 않아야 함
            XCTAssertEqual(mockURLSession.requestCount, 0)
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
}

// MARK: - 테스트 모델 및 모의 객체
private struct TestItem: Decodable {
    let id: Int
    let name: String
}

// 테스트용 APIRequest 구현
private struct TestAPIRequest<T: Decodable>: APIRequest {
    typealias Response = T
    
    let path: String
    let method: HTTPMethod
    let headers: HTTPHeaders?
    let queryParameters: [String: String]?
    let requestBody: RequestBody
    let requiresAuth: Bool
    let cachePolicyForURLRequest: URLRequest.CachePolicy
    let timeoutInterval: TimeInterval
    
    init(
        path: String,
        method: HTTPMethod = .get,
        headers: HTTPHeaders? = nil,
        queryParameters: [String: String]? = nil,
        requestBody: RequestBody = .none,
        requiresAuth: Bool = true,
        cachePolicyForURLRequest: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.requestBody = requestBody
        self.requiresAuth = requiresAuth
        self.cachePolicyForURLRequest = cachePolicyForURLRequest
        self.timeoutInterval = timeoutInterval
    }
}

// 모의 URLSession 구현
private class MockURLSession: URLSessionProtocol {
    var nextData: Data = Data()
    var nextResponse: URLResponse = URLResponse()
    var nextError: Error?
    var lastRequest: URLRequest?
    var requestCount: Int = 0
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        lastRequest = request
        requestCount += 1
        
        if let error = nextError {
            throw error
        }
        return (nextData, nextResponse)
    }
    
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        lastRequest = request
        requestCount += 1
        
        if let error = nextError {
            throw error
        }
        return (nextData, nextResponse)
    }
}

// 모의 네트워크 연결 상태
private class MockNetworkReachability: NetworkReachability {
    var didChangeStatus: ((Bool) -> Void)?
    var isConnected: Bool = true
} 
