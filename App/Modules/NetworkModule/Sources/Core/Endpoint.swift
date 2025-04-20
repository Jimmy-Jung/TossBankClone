import Foundation

/// 공용 API 엔드포인트 정의
/// 이전의 APIEndpoint와 통합된 구현입니다.
public struct Endpoint<Response: Decodable>: APIRequest {
    public typealias Response = Response
    
    public let path: String
    public let method: HTTPMethod
    public let headers: HTTPHeaders?
    public let queryParameters: [String: String]?
    public let bodyParameters: Encodable?
    public let bodyDict: [String: Any]?
    public let requiresAuth: Bool
    public let cachePolicyForURLRequest: URLRequest.CachePolicy
    public let timeoutInterval: TimeInterval
    
    /// Endpoint 생성자 (Encodable 파라미터)
    public init(
        path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders? = nil,
        queryParameters: [String: String]? = nil,
        bodyParameters: Encodable? = nil,
        requiresAuth: Bool = true,
        cachePolicyForURLRequest: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = bodyParameters
        self.bodyDict = nil
        self.requiresAuth = requiresAuth
        self.cachePolicyForURLRequest = cachePolicyForURLRequest
        self.timeoutInterval = timeoutInterval
    }
    
    /// Endpoint 생성자 (Dictionary 파라미터)
    public init(
        path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders? = nil,
        queryParameters: [String: String]? = nil,
        bodyDict: [String: Any]? = nil,
        requiresAuth: Bool = true,
        cachePolicyForURLRequest: URLRequest.CachePolicy = .useProtocolCachePolicy,
        timeoutInterval: TimeInterval = 30.0
    ) {
        self.path = path
        self.method = method
        self.headers = headers
        self.queryParameters = queryParameters
        self.bodyParameters = nil
        self.bodyDict = bodyDict
        self.requiresAuth = requiresAuth
        self.cachePolicyForURLRequest = cachePolicyForURLRequest
        self.timeoutInterval = timeoutInterval
    }
    
    /// URL 요청으로 변환
    public func asURLRequest(baseURL: URL) throws -> URLRequest {
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
        
        // 바디 파라미터 설정
        if let bodyParameters = bodyParameters {
            do {
                let data = try JSONEncoder().encode(bodyParameters)
                request.httpBody = data
            } catch {
                throw NetworkError.invalidURL
            }
        } else if let bodyDict = bodyDict {
            do {
                let data = try JSONSerialization.data(withJSONObject: bodyDict)
                request.httpBody = data
            } catch {
                throw NetworkError.invalidURL
            }
        }
        
        return request
    }
}

// MARK: - Builder 패턴
public extension Endpoint {
    /// 새로운 PATH로 Endpoint 생성
    func path(_ path: String) -> Endpoint<Response> {
        Endpoint<Response>(
            path: path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 새로운 HTTP 메서드로 Endpoint 생성
    func method(_ method: HTTPMethod) -> Endpoint<Response> {
        Endpoint<Response>(
            path: self.path,
            method: method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 헤더 추가하여 새 Endpoint 생성
    func addHeaders(_ additionalHeaders: HTTPHeaders) -> Endpoint<Response> {
        var newHeaders = self.headers ?? [:]
        additionalHeaders.forEach { newHeaders[$0.key] = $0.value }
        
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: newHeaders,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 쿼리 파라미터 추가하여 새 Endpoint 생성
    func addQueryParameters(_ additionalParameters: [String: String]) -> Endpoint<Response> {
        var newParameters = self.queryParameters ?? [:]
        additionalParameters.forEach { newParameters[$0.key] = $0.value }
        
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: newParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 바디 파라미터 설정하여 새 Endpoint 생성 (Encodable)
    func body(_ parameters: Encodable) -> Endpoint<Response> {
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: parameters,
            bodyDict: nil,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 바디 파라미터 설정하여 새 Endpoint 생성 (Dictionary)
    func bodyDict(_ parameters: [String: Any]) -> Endpoint<Response> {
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: nil,
            bodyDict: parameters,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 인증 요구 설정하여 새 Endpoint 생성 
    func requiresAuth(_ requires: Bool) -> Endpoint<Response> {
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: requires,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 캐시 정책 설정하여 새 Endpoint 생성
    func cachePolicy(_ policy: URLRequest.CachePolicy) -> Endpoint<Response> {
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: policy,
            timeoutInterval: self.timeoutInterval
        )
    }
    
    /// 타임아웃 설정하여 새 Endpoint 생성
    func timeout(_ interval: TimeInterval) -> Endpoint<Response> {
        return Endpoint<Response>(
            path: self.path,
            method: self.method,
            headers: self.headers,
            queryParameters: self.queryParameters,
            bodyParameters: self.bodyParameters,
            bodyDict: self.bodyDict,
            requiresAuth: self.requiresAuth,
            cachePolicyForURLRequest: self.cachePolicyForURLRequest,
            timeoutInterval: interval
        )
    }
} 