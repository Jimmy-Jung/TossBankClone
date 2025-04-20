import XCTest
@testable import NetworkModule

class EndpointTests: XCTestCase {
    
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
    func testBasicEndpointCreation() throws {
        // Given
        let endpoint = Endpoint<TestModel>(path: "/users")
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/users")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    // MARK: - HTTP 메서드 테스트
    func testHTTPMethodConfiguration() throws {
        // Given
        let getEndpoint = Endpoint<TestModel>(path: "/users", method: .GET)
        let postEndpoint = Endpoint<TestModel>(path: "/users", method: .POST)
        let putEndpoint = Endpoint<TestModel>(path: "/users/1", method: .PUT)
        let deleteEndpoint = Endpoint<TestModel>(path: "/users/1", method: .DELETE)
        
        // When
        let getRequest = try getEndpoint.asURLRequest(baseURL: baseURL)
        let postRequest = try postEndpoint.asURLRequest(baseURL: baseURL)
        let putRequest = try putEndpoint.asURLRequest(baseURL: baseURL)
        let deleteRequest = try deleteEndpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(getRequest.httpMethod, "GET")
        XCTAssertEqual(postRequest.httpMethod, "POST")
        XCTAssertEqual(putRequest.httpMethod, "PUT")
        XCTAssertEqual(deleteRequest.httpMethod, "DELETE")
    }
    
    // MARK: - 쿼리 파라미터 테스트
    func testQueryParameters() throws {
        // Given
        let endpoint = Endpoint<TestModel>(
            path: "/search",
            queryParameters: [
                "q": "swift",
                "page": "1",
                "limit": "10"
            ]
        )
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
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
        let endpoint = Endpoint<TestModel>(
            path: "/users",
            headers: [
                "X-API-Key": "test-api-key",
                "X-Custom-Header": "custom-value"
            ]
        )
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "test-api-key")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-Custom-Header"), "custom-value")
        // 기본 헤더는 그대로 유지되어야 함
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }
    
    // MARK: - RequestBody 테스트
    func testRequestBodyEncodable() throws {
        // Given
        struct UserData: Codable {
            let name: String
            let email: String
        }
        
        let userData = UserData(name: "테스트 사용자", email: "test@example.com")
        let endpoint = Endpoint<TestModel>(
            path: "/users", 
            method: .POST,
            requestBody: .encodable(userData)
        )
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(request.httpBody)
        
        // 바디 데이터 디코딩하여 검증
        if let httpBody = request.httpBody {
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
        
        let endpoint = Endpoint<TestModel>(
            path: "/users",
            method: .POST,
            requestBody: .dictionary(bodyDict)
        )
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(request.httpBody)
        
        // 바디 데이터 추출하여 검증
        if let httpBody = request.httpBody, 
           let jsonDict = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any] {
            XCTAssertEqual(jsonDict["name"] as? String, "테스트 사용자")
            XCTAssertEqual(jsonDict["email"] as? String, "test@example.com")
        } else {
            XCTFail("HTTP 바디를 JSON으로 파싱할 수 없습니다")
        }
    }
    
    func testBodyBuilder() throws {
        // Given
        struct UserData: Codable {
            let name: String
            let email: String
        }
        
        let userData = UserData(name: "테스트 사용자", email: "test@example.com")
        let endpoint = Endpoint<TestModel>(path: "/users", method: .POST)
            .body(userData)
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(request.httpBody)
        
        // 바디 데이터 디코딩하여 검증
        if let httpBody = request.httpBody {
            let decodedData = try JSONDecoder().decode(UserData.self, from: httpBody)
            XCTAssertEqual(decodedData.name, "테스트 사용자")
            XCTAssertEqual(decodedData.email, "test@example.com")
        } else {
            XCTFail("HTTP 바디가 없습니다")
        }
    }
    
    func testBodyDictBuilder() throws {
        // Given
        let bodyDict: [String: Any] = [
            "name": "테스트 사용자",
            "email": "test@example.com"
        ]
        
        let endpoint = Endpoint<TestModel>(path: "/users", method: .POST)
            .bodyDict(bodyDict)
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(request.httpBody)
        
        // 바디 데이터 추출하여 검증
        if let httpBody = request.httpBody, 
           let jsonDict = try? JSONSerialization.jsonObject(with: httpBody) as? [String: Any] {
            XCTAssertEqual(jsonDict["name"] as? String, "테스트 사용자")
            XCTAssertEqual(jsonDict["email"] as? String, "test@example.com")
        } else {
            XCTFail("HTTP 바디를 JSON으로 파싱할 수 없습니다")
        }
    }
    
    // MARK: - 테스트 requestBody 통합 메서드
    func testRequestBodyMethod() throws {
        // Given
        struct UserData: Codable {
            let name: String
        }
        
        let userData = UserData(name: "테스트 사용자")
        let endpoint = Endpoint<TestModel>(path: "/users", method: .POST)
            .requestBody(.encodable(userData))
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertNotNil(request.httpBody)
        
        // 바디 데이터 디코딩하여 검증
        if let httpBody = request.httpBody {
            let decodedData = try JSONDecoder().decode(UserData.self, from: httpBody)
            XCTAssertEqual(decodedData.name, "테스트 사용자")
        } else {
            XCTFail("HTTP 바디가 없습니다")
        }
    }
    
    // MARK: - 캐시 설정 테스트
    func testCachePolicy() throws {
        // Given
        let endpoint = Endpoint<TestModel>(path: "/users")
            .cachePolicy(.returnCacheDataDontLoad)
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(request.cachePolicy, .returnCacheDataDontLoad)
    }
    
    // MARK: - 타임아웃 설정 테스트
    func testTimeoutInterval() throws {
        // Given
        let endpoint = Endpoint<TestModel>(path: "/users")
            .timeout(60.0)
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        
        // Then
        XCTAssertEqual(request.timeoutInterval, 60.0)
    }
    
    // MARK: - 메서드 체이닝 테스트
    func testMethodChaining() throws {
        // Given
        struct UserData: Codable {
            let name: String
        }
        
        let endpoint = Endpoint<TestModel>(path: "/users")
            .method(.POST)
            .body(UserData(name: "테스트 사용자"))
            .addHeaders(["X-API-Key": "test-key"])
            .addQueryParameters(["source": "ios"])
            .timeout(45.0)
            .cachePolicy(.reloadIgnoringLocalCacheData)
        
        // When
        let request = try endpoint.asURLRequest(baseURL: baseURL)
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        
        // Then
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-API-Key"), "test-key")
        XCTAssertEqual(components?.queryItems?.first?.name, "source")
        XCTAssertEqual(components?.queryItems?.first?.value, "ios")
        XCTAssertEqual(request.timeoutInterval, 45.0)
        XCTAssertEqual(request.cachePolicy, .reloadIgnoringLocalCacheData)
        
        // 바디 데이터 검증
        if let httpBody = request.httpBody {
            let decodedData = try JSONDecoder().decode(UserData.self, from: httpBody)
            XCTAssertEqual(decodedData.name, "테스트 사용자")
        } else {
            XCTFail("HTTP 바디가 없습니다")
        }
    }
}

// MARK: - 테스트 모델
private struct TestModel: Decodable {
    let id: Int
    let name: String
} 
