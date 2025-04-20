import Foundation

/// HTTP 메서드 타입
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE, PATCH
}

/// HTTP 헤더 타입
public typealias HTTPHeaders = [String: String]

/// API 요청 프로토콜
public protocol APIRequest {
    /// 응답 타입
    associatedtype Response: Decodable
    
    /// API 엔드포인트 경로
    var path: String { get }
    
    /// HTTP 메서드
    var method: HTTPMethod { get }
    
    /// HTTP 헤더
    var headers: HTTPHeaders? { get }
    
    /// 쿼리 파라미터
    var queryParameters: [String: String]? { get }
    
    /// 바디 파라미터
    var bodyParameters: Encodable? { get }
    
    /// 인증 필요 여부
    var requiresAuth: Bool { get }
    
    /// URL 요청의 캐시 정책
    var cachePolicyForURLRequest: URLRequest.CachePolicy { get }
    
    /// 타임아웃 간격
    var timeoutInterval: TimeInterval { get }
    
    /// URL 요청으로 변환
    func asURLRequest(baseURL: URL) throws -> URLRequest
}

/// API 요청 기본 구현
public extension APIRequest {
    var headers: HTTPHeaders? { return nil }
    var queryParameters: [String: String]? { return nil }
    var bodyParameters: Encodable? { return nil }
    var requiresAuth: Bool { return true }
    var cachePolicyForURLRequest: URLRequest.CachePolicy { return .useProtocolCachePolicy }
    var timeoutInterval: TimeInterval { return 30.0 }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        guard var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }
        
        // 쿼리 파라미터 설정
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = cachePolicyForURLRequest
        request.timeoutInterval = timeoutInterval
        
        // 기본 헤더 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // 추가 헤더 설정
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
} 