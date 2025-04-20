import XCTest
@testable import NetworkModule

class NetworkPluginTests: XCTestCase {
    
    // MARK: - ConnectivityPlugin 테스트
    
    func testConnectivityPluginBlocksRequestWhenOffline() async {
        // Given
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = false
        
        let plugin = ConnectivityPlugin(reachability: mockReachability)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When/Then
        do {
            try await plugin.prepare(&request)
            XCTFail("오프라인 상태에서 요청이 차단되지 않았습니다")
        } catch let error as NetworkError {
            XCTAssertEqual(error, NetworkError.offline)
        } catch {
            XCTFail("예상치 못한 오류 타입입니다: \(error)")
        }
    }
    
    func testConnectivityPluginAllowsRequestWhenOnline() async throws {
        // Given
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true
        
        let plugin = ConnectivityPlugin(reachability: mockReachability)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When/Then
        // 온라인 상태에서는 예외가 발생하지 않아야 함
        try await plugin.prepare(&request)
    }
    
    // MARK: - AuthPlugin 테스트
    
    func testAuthPluginAddsTokenToRequest() async throws {
        // Given
        let tokenProvider = { return "test-token" }
        let plugin = AuthPlugin(tokenProvider: tokenProvider)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When
        try await plugin.prepare(&request)
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
    }
    
    func testAuthPluginHandlesNilToken() async throws {
        // Given
        let tokenProvider = { return nil as String? }
        let plugin = AuthPlugin(tokenProvider: tokenProvider)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // When
        try await plugin.prepare(&request)
        
        // Then
        XCTAssertNil(request.value(forHTTPHeaderField: "Authorization"))
    }
    
    // MARK: - LoggingPlugin 테스트
    
    func testLoggingPluginLogsRequestAndResponse() async throws {
        // Given
        let mockLogger = MockLogger()
        let plugin = LoggingPlugin(logger: mockLogger)
        
        var request = URLRequest(url: URL(string: "https://example.com/test")!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let responseData = #"{"message": "success"}"#.data(using: .utf8)!
        
        // When
        try await plugin.prepare(&request)
        try await plugin.process(request, response, responseData)
        
        // Then
        XCTAssertTrue(mockLogger.didLogRequest)
        XCTAssertTrue(mockLogger.didLogResponse)
        XCTAssertEqual(mockLogger.lastRequestURL, "https://example.com/test")
        XCTAssertEqual(mockLogger.lastStatusCode, 200)
    }
    
    // MARK: - CachePlugin 테스트
    
    func testCachePluginStoresAndRetrievesData() async throws {
        // Given
        let mockCache = MockNetworkCache()
        let plugin = CachePlugin(cache: mockCache)
        
        let request = URLRequest(url: URL(string: "https://example.com/cached")!)
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com/cached")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let responseData = #"{"id": 1, "name": "Cached Item"}"#.data(using: .utf8)!
        
        // When
        try await plugin.process(request, response, responseData)
        
        // Then
        // 캐시에 데이터가 저장되었는지 확인
        XCTAssertTrue(mockCache.didStoreData)
        XCTAssertEqual(mockCache.lastStoredData, responseData)
        XCTAssertEqual(mockCache.lastStoredRequest?.url, request.url)
    }
    
    // MARK: - TimeoutPlugin 테스트
    
    func testTimeoutPluginSetsRequestTimeout() async throws {
        // Given
        let timeout: TimeInterval = 60.0
        let plugin = TimeoutPlugin(timeout: timeout)
        var request = URLRequest(url: URL(string: "https://example.com")!)
        
        // 기본 타임아웃 값
        request.timeoutInterval = 30.0
        
        // When
        try await plugin.prepare(&request)
        
        // Then
        XCTAssertEqual(request.timeoutInterval, timeout)
    }
    
    // MARK: - 플러그인 조합 테스트
    
    func testMultiplePluginsInChain() async throws {
        // Given
        let mockReachability = MockNetworkReachability()
        mockReachability.isConnected = true
        
        let connectivityPlugin = ConnectivityPlugin(reachability: mockReachability)
        let tokenProvider = { return "test-token" }
        let authPlugin = AuthPlugin(tokenProvider: tokenProvider)
        let timeoutPlugin = TimeoutPlugin(timeout: 45.0)
        
        var request = URLRequest(url: URL(string: "https://example.com")!)
        request.timeoutInterval = 30.0
        
        // When
        try await connectivityPlugin.prepare(&request)
        try await authPlugin.prepare(&request)
        try await timeoutPlugin.prepare(&request)
        
        // Then
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
        XCTAssertEqual(request.timeoutInterval, 45.0)
    }
}

// MARK: - 목 객체
private class MockNetworkReachability: NetworkReachability {
    var isConnected: Bool = true
}

private class MockLogger {
    var didLogRequest = false
    var didLogResponse = false
    var lastRequestURL: String?
    var lastStatusCode: Int?
    
    func logRequest(_ request: URLRequest) {
        didLogRequest = true
        lastRequestURL = request.url?.absoluteString
    }
    
    func logResponse(_ response: HTTPURLResponse, data: Data) {
        didLogResponse = true
        lastStatusCode = response.statusCode
    }
}

private class MockNetworkCache {
    var didStoreData = false
    var lastStoredRequest: URLRequest?
    var lastStoredData: Data?
    
    func storeResponse(for request: URLRequest, data: Data) {
        didStoreData = true
        lastStoredRequest = request
        lastStoredData = data
    }
    
    func retrieveResponse(for request: URLRequest) -> Data? {
        return lastStoredData
    }
} 