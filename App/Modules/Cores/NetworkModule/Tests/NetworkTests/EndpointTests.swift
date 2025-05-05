import XCTest
@testable import NetworkModule

class APIRequestTests: XCTestCase {
    
    // MARK: - 테스트 대상
    private var baseURL: URL!
    
    // MARK: - 셋업 및 테어다운
    override func setUp() {
        super.setUp()
        baseURL = URL(string: "https://api.example.com")!
    }
    
    override func tearDown() {
        baseURL = nil
        super.tearDown()
    }
    
    // MARK: - 기본 설정 테스트
    func testBasicAPIRequestCreation() throws {
        // Given
        let request = TestAPIRequest<TestModel>(path: "/users")
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(urlRequest.url?.absoluteString, "https://api.example.com/users")
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    // MARK: - HTTP 메서드 테스트
    func testHTTPMethodConfiguration() throws {
        // Given
        let getRequest = TestAPIRequest<TestModel>(path: "/users", method: .get)
        let postRequest = TestAPIRequest<TestModel>(path: "/users", method: .post)
        let putRequest = TestAPIRequest<TestModel>(path: "/users/1", method: .put)
        let deleteRequest = TestAPIRequest<TestModel>(path: "/users/1", method: .delete)
        
        // When
        let getUrlRequest = try getRequest.asURLRequest(baseURL: baseURL)
        let postUrlRequest = try postRequest.asURLRequest(baseURL: baseURL)
        let putUrlRequest = try putRequest.asURLRequest(baseURL: baseURL)
        let deleteUrlRequest = try deleteRequest.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(getUrlRequest.httpMethod, "GET")
        XCTAssertEqual(postUrlRequest.httpMethod, "POST")
        XCTAssertEqual(putUrlRequest.httpMethod, "PUT")
        XCTAssertEqual(deleteUrlRequest.httpMethod, "DELETE")
    }
    
    // MARK: - 쿼리 파라미터 테스트
    func testQueryParameters() throws {
        // Given
        let request = TestAPIRequest<TestModel>(
            path: "/search",
            queryParameters: [
                "q": "swift",
                "page": "1",
                "limit": "10"
            ]
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        let components = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems?.sorted(by: { $0.name < $1.name })
        
        // Then
        XCTAssertEqual(queryItems?.count, 3)
        XCTAssertEqual(queryItems?[0].name, "limit")
        XCTAssertEqual(queryItems?[0].value, "10")
        XCTAssertEqual(queryItems?[1].name, "page")
        XCTAssertEqual(queryItems?[1].value, "1")
        XCTAssertEqual(queryItems?[2].name, "q")
        XCTAssertEqual(queryItems?[2].value, "swift")
    }
    
    // MARK: - 헤더 설정 테스트
    func testCustomHeaders() throws {
        // Given
        let request = TestAPIRequest<TestModel>(
            path: "/users",
            headers: [
                "X-API-Key": "test-api-key",
                "X-Custom-Header": "custom-value"
            ]
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-API-Key"), "test-api-key")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "X-Custom-Header"), "custom-value")
        // 기본 헤더는 그대로 유지되어야 함
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(urlRequest.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    // MARK: - RequestBody 테스트
    func testRequestBodyEncodable() throws {
        // Given
        struct UserData: Codable {
            let name: String
            let email: String
        }
        
        let userData = UserData(name: "테스트 사용자", email: "test@example.com")
        let request = TestAPIRequest<TestModel>(
            path: "/users", 
            method: .post,
            requestBody: .encodable(userData)
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(urlRequest.httpBody)
        
        // 바디 데이터 디코딩하여 검증
        if let httpBody = urlRequest.httpBody {
            let decodedData = try JSONDecoder().decode(UserData.self, from: httpBody)
            XCTAssertEqual(decodedData.name, "테스트 사용자")
            XCTAssertEqual(decodedData.email, "test@example.com")
        } else {
            XCTFail("HTTP 바디가 없습니다")
        }
    }
    
    func testRequestBodyDictionary() throws {
        // Given
        let bodyDict: [String: Any] = [
            "name": "테스트 사용자",
            "email": "test@example.com"
        ]
        
        let request = TestAPIRequest<TestModel>(
            path: "/users",
            method: .post,
            requestBody: .dictionary(bodyDict)
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(urlRequest.httpBody)
        
        // 바디 데이터 추출하여 검증
        if let httpBody = urlRequest.httpBody, 
           let jsonDict = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any] {
            XCTAssertEqual(jsonDict["name"] as? String, "테스트 사용자")
            XCTAssertEqual(jsonDict["email"] as? String, "test@example.com")
        } else {
            XCTFail("HTTP 바디를 JSON으로 파싱할 수 없습니다")
        }
    }
    
    func testRequestBodyJson() throws {
        // Given
        let jsonBody: [String: Any] = [
            "name": "테스트 사용자",
            "email": "test@example.com"
        ]
        
        let request = TestAPIRequest<TestModel>(
            path: "/users",
            method: .post,
            requestBody: .json(jsonBody)
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(urlRequest.httpBody)
        
        // 바디 데이터 추출하여 검증
        if let httpBody = urlRequest.httpBody, 
           let jsonDict = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any] {
            XCTAssertEqual(jsonDict["name"] as? String, "테스트 사용자")
            XCTAssertEqual(jsonDict["email"] as? String, "test@example.com")
        } else {
            XCTFail("HTTP 바디를 JSON으로 파싱할 수 없습니다")
        }
    }
    
    // MARK: - 캐시 및 타임아웃 설정 테스트
    func testCachePolicy() throws {
        // Given
        let request = TestAPIRequest<TestModel>(
            path: "/users",
            cachePolicyForURLRequest: .returnCacheDataDontLoad
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(urlRequest.cachePolicy, .returnCacheDataDontLoad)
    }
    
    func testTimeoutInterval() throws {
        // Given
        let request = TestAPIRequest<TestModel>(
            path: "/large-data",
            timeoutInterval: 60.0
        )
        
        // When
        let urlRequest = try request.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(urlRequest.timeoutInterval, 60.0)
    }
    
    // MARK: - 인증 필요 여부 테스트
    func testRequiresAuth() throws {
        // Given
        let authenticatedRequest = TestAPIRequest<TestModel>(
            path: "/secure",
            requiresAuth: true
        )
        
        let publicRequest = TestAPIRequest<TestModel>(
            path: "/public",
            requiresAuth: false
        )
        
        // Then
        XCTAssertTrue(authenticatedRequest.requiresAuth)
        XCTAssertFalse(publicRequest.requiresAuth)
    }
}

// MARK: - 테스트 모델 및 헬퍼
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
