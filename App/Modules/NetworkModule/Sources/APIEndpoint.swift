import Foundation

public protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, data: Data)
    case decodingError(Error)
    case networkError(Error)
    case unauthorized
    case noInternetConnection
    case timeout
}

public struct APIConfiguration {
    public let baseURL: URL
    public let headers: [String: String]
    
    public init(baseURL: URL, headers: [String: String] = [:]) {
        self.baseURL = baseURL
        self.headers = headers
    }
}

public protocol NetworkPlugin {
    func prepare(_ request: inout URLRequest) async throws
    func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws
}

// 기본 엔드포인트 구현
public struct BaseAPIEndpoint: APIEndpoint {
    public let path: String
    public let method: HTTPMethod
    public let queryParameters: [String: String]?
    public let bodyParameters: [String: Any]?
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        queryParameters: [String: String]? = nil,
        bodyParameters: [String: Any]? = nil
    ) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
    }
    
    public func asURLRequest(baseURL: URL) throws -> URLRequest {
        // URL 생성
        var urlComponents = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host = baseURL.host
        urlComponents.port = baseURL.port
        urlComponents.path = baseURL.path + path
        
        // 쿼리 파라미터 추가
        if let queryParams = queryParameters, !queryParams.isEmpty {
            urlComponents.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // URL 요청 생성
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // 바디 파라미터 추가
        if let bodyParams = bodyParameters, !bodyParams.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: bodyParams)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.invalidURL
            }
        }
        
        return request
    }
} 