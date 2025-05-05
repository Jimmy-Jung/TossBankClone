import Foundation
import Combine

/// 테스트를 위한 가짜 네트워크 서비스
public final class MockNetworkService: NetworkServiceProtocol {
    // MARK: - 타입
    public typealias RequestHandler = (URLRequest) -> (Data?, URLResponse?, Error?)
    
    // MARK: - 속성
    private var requestHandlers: [String: RequestHandler] = [:]
    private var capturedRequests: [URLRequest] = []
    private var defaultHandler: RequestHandler?
    private let baseURL: URL
    
    // MARK: - 초기화
    public init(baseURL: URL = URL(string: "https://example.com")!) {
        self.baseURL = baseURL
    }
    
    // MARK: - 테스트 설정 메서드
    /// 특정 경로에 대한 응답 핸들러 설정
    public func setRequestHandler(for path: String, handler: @escaping RequestHandler) {
        requestHandlers[path] = handler
    }
    
    /// 모든 경로에 대한 기본 응답 핸들러 설정
    public func setDefaultHandler(_ handler: @escaping RequestHandler) {
        defaultHandler = handler
    }
    
    /// 성공 응답 설정 (편의 메서드)
    public func setSuccessResponse<T: Encodable>(for path: String, data: T, statusCode: Int = 200) {
        do {
            let jsonData = try JSONEncoder().encode(data)
            setRequestHandler(for: path) { request in
                let url = request.url ?? URL(string: "https://example.com")!
                let response = HTTPURLResponse(
                    url: url,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )
                return (jsonData, response, nil)
            }
        } catch {
            print("MockNetworkService: 데이터 인코딩 오류 - \(error)")
        }
    }
    
    /// 오류 응답 설정 (편의 메서드)
    public func setErrorResponse(for path: String, error: Error) {
        setRequestHandler(for: path) { _ in
            return (nil, nil, error)
        }
    }
    
    /// HTTP 오류 응답 설정 (편의 메서드)
    public func setHTTPErrorResponse(for path: String, statusCode: Int, errorData: Data? = nil) {
        setRequestHandler(for: path) { request in
            let url = request.url ?? URL(string: "https://example.com")!
            let response = HTTPURLResponse(
                url: url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )
            return (errorData, response, nil)
        }
    }
    
    /// 캡처된 요청 가져오기
    public func getCapturedRequests() -> [URLRequest] {
        return capturedRequests
    }
    
    /// 캡처된 요청 초기화
    public func clearCapturedRequests() {
        capturedRequests.removeAll()
    }
    
    // MARK: - NetworkServiceProtocol 구현
    public func request<R: APIRequest>(_ apiRequest: R) async throws -> R.Response {
        // APIRequest를 URLRequest로 변환
        let urlRequest = try apiRequest.asURLRequest(baseURL: baseURL)
        return try await processRequest(urlRequest)
    }
    
    public func upload<R: APIRequest>(_ apiRequest: R, data: Data, mimeType: String) async throws -> R.Response {
        // APIRequest를 URLRequest로 변환
        var urlRequest = try apiRequest.asURLRequest(baseURL: baseURL)
        
        // 업로드 설정
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data
        
        return try await processRequest(urlRequest)
    }
    
    // MARK: - 내부 메서드
    private func processRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        capturedRequests.append(request)
        
        // 요청 경로 추출
        let path = request.url?.path ?? ""
        
        // 해당 경로에 대한 핸들러 또는 기본 핸들러 실행
        let handler = requestHandlers[path] ?? defaultHandler
        
        guard let handler = handler else {
            throw NetworkError.invalidResponse
        }
        
        let (data, response, error) = handler(request)
        
        if let error = error {
            throw error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode), let data = data else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data ?? Data())
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
} 