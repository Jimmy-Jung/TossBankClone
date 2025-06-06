import XCTest
@testable import NetworkModule

class NetworkServiceTests: XCTestCase {
    
    // MARK: - 테스트 대상 및 모의 객체
    private var sut: NetworkService!
    private var mockURLSession: MockURLSession!
    private var mockReachability: MockNetworkReachability!
    private var baseURL: URL!
    
    // MARK: - 셋업 및 테어다운
    override func setUp() {
        super.setUp()
        
        baseURL = URL(string: "https://api.example.com")!
        mockURLSession = MockURLSession()
        mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true
        
        sut = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [],
            reachability: mockReachability
        )
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        mockReachability = nil
        baseURL = nil
        
        super.tearDown()
    }
    
    // MARK: - 성공 테스트
    func testRequestSuccess() async throws {
        // Given
        let expectedData = #"{"id": 1, "name": "테스트"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = expectedData
        mockURLSession.nextResponse = response
        
        let testRequest = TestAPIRequest<TestModel>(path: "/test")
        let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
        
        // When
        let result = try await sut.request(urlRequest, responseType: TestModel.self)
        
        // Then
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "테스트")
    }
    
    func testUploadSuccess() async throws {
        // Given
        let expectedData = #"{"id": 2, "name": "업로드 테스트"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = expectedData
        mockURLSession.nextResponse = response
        
        let testRequest = TestAPIRequest<TestModel>(path: "/upload", method: .post)
        let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
        let uploadData = "테스트 데이터".data(using: .utf8)!
        
        // When
        let result = try await sut.upload(urlRequest, data: uploadData, mimeType: "text/plain", responseType: TestModel.self)
        
        // Then
        XCTAssertEqual(result.id, 2)
        XCTAssertEqual(result.name, "업로드 테스트")
    }
    
    // MARK: - 실패 테스트
    func testRequestFailure() async {
        // Given
        let errorData = #"{"error": "Not found"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL, statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = errorData
        mockURLSession.nextResponse = response
        
        let testRequest = TestAPIRequest<TestModel>(path: "/not-found")
        
        // When/Then
        do {
            let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
            _ = try await sut.request(urlRequest, responseType: TestModel.self)
            XCTFail("요청이 성공해서는 안됩니다")
        } catch let error as NetworkError {
            if case .httpError(let statusCode, _) = error {
                XCTAssertEqual(statusCode, 404)
            } else {
                XCTFail("예상된 오류 타입이 아닙니다: \(error)")
            }
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
    
    func testConnectionFailure() async {
        // Given
        mockReachability.isConnected = false
        let connectivityPlugin = ConnectivityPlugin(reachability: mockReachability)
        
        sut = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [connectivityPlugin],
            reachability: mockReachability
        )
        
        let testRequest = TestAPIRequest<TestModel>(path: "/test")
        
        // When/Then
        do {
            let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
            _ = try await sut.request(urlRequest, responseType: TestModel.self)
            XCTFail("인터넷 연결이 없을 때 요청이 성공해서는 안됩니다")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.offline)
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
    
    // MARK: - 플러그인 테스트
    func testPluginExecution() async throws {
        // Given
        let testPlugin = TestPlugin()
        
        sut = NetworkService(
            baseURL: baseURL,
            session: mockURLSession,
            plugins: [testPlugin],
            reachability: mockReachability
        )
        
        let expectedData = #"{"id": 1, "name": "테스트"}"#.data(using: .utf8)!
        let response = HTTPURLResponse(url: baseURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        mockURLSession.nextData = expectedData
        mockURLSession.nextResponse = response
        
        let testRequest = TestAPIRequest<TestModel>(path: "/test")
        let urlRequest = try testRequest.asURLRequest(baseURL: baseURL)
        
        // When
        _ = try await sut.request(urlRequest, responseType: TestModel.self)
        
        // Then
        XCTAssertTrue(testPlugin.prepareWasCalled)
        XCTAssertTrue(testPlugin.processWasCalled)
    }
}

// MARK: - 테스트용 모델
private struct TestModel: Decodable {
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

// MARK: - 모의 URLSession
private class MockURLSession: URLSessionProtocol {
    var nextData: Data = Data()
    var nextResponse: URLResponse = URLResponse()
    var nextError: Error?
    
     func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = nextError {
            throw error
        }
        return (nextData, nextResponse)
    }
    
     func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse) {
        if let error = nextError {
            throw error
        }
        return (nextData, nextResponse)
    }
}

// MARK: - 모의 네트워크 연결 상태
private class MockNetworkReachability: NetworkReachability {
    var didChangeStatus: ((Bool) -> Void)?
    var isConnected: Bool = true
}

// MARK: - 테스트 플러그인
private class TestPlugin: NetworkPlugin {
    var prepareWasCalled = false
    var processWasCalled = false
    
    func prepare(_ request: inout URLRequest) async throws {
        prepareWasCalled = true
    }
    
    func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        processWasCalled = true
    }
} 
