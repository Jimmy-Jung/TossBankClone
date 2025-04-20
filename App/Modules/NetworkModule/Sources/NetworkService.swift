import Foundation
import Combine

/// URLSession 프로토콜 - 테스트 용이성을 위한 추상화
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
    func upload(for request: URLRequest, from bodyData: Data) async throws -> (Data, URLResponse)
}

/// URLSession을 URLSessionProtocol로 확장
extension URLSession: URLSessionProtocol { }

/// 네트워크 서비스 인터페이스
public protocol NetworkServiceProtocol {
    /// URLRequest를 사용한 요청
    func request<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T
    
    /// 파일 업로드 요청
    func upload<T: Decodable>(_ request: URLRequest, data: Data, mimeType: String, responseType: T.Type) async throws -> T
}

/// 네트워크 서비스 구현체
public final class NetworkService: NetworkServiceProtocol {
    // MARK: - 속성
    private let baseURL: URL
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let plugins: [NetworkPlugin]
    private let reachability: NetworkReachability
    
    // MARK: - 초기화
    /// 네트워크 서비스 초기화
    /// - Parameters:
    ///   - baseURL: 기본 URL
    ///   - session: URLSessionProtocol (기본값: URLSession.shared)
    ///   - decoder: JSONDecoder (기본값: JSONDecoder())
    ///   - encoder: JSONEncoder (기본값: JSONEncoder())
    ///   - plugins: 플러그인 배열 (기본값: [])
    ///   - reachability: 네트워크 연결 상태 모니터링 객체 (기본값: NetworkReachabilityImpl.shared)
    ///   - ConnectivityPlugin: 네트워크 연결 상태 플러그인 (기본값: ConnectivityPlugin(reachability: reachability))
    ///   - RetryPlugin: 네트워크 요청 재시도 플러그인 (기본값: RetryPlugin())
    public init(
        baseURL: URL,
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        plugins: [NetworkPlugin] = [],
        reachability: NetworkReachability = NetworkReachabilityImpl.shared
    ) {
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
        self.reachability = reachability
        
        // 기본 설정
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder.dateEncodingStrategy = .iso8601
        
        // 기본 플러그인 설정
        var allPlugins = plugins
        
        // ConnectivityPlugin이 이미 추가되어 있지 않으면 추가
        if !plugins.contains(where: { $0 is ConnectivityPlugin }) {
            allPlugins.append(ConnectivityPlugin(reachability: reachability))
        }
        
        // RetryPlugin이 이미 추가되어 있지 않으면 추가
        if !plugins.contains(where: { $0 is RetryPlugin }) {
            allPlugins.append(RetryPlugin())
        }
        
        self.plugins = allPlugins
    }
    
    /// 인증 토큰 제공자를 사용하는 초기화 메서드
    public convenience init(
        baseURL: URL,
        authTokenProvider: @escaping () -> String?,
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder(),
        plugins: [NetworkPlugin] = [],
        reachability: NetworkReachability = NetworkReachabilityImpl.shared
    ) {
        // 기본 플러그인에 인증 플러그인 추가
        var allPlugins = plugins
        
        // AuthPlugin 추가
        let authPlugin = AuthPlugin(tokenProvider: authTokenProvider)
        if !plugins.contains(where: { $0 is AuthPlugin }) {
            allPlugins.append(authPlugin)
        }
        
        self.init(
            baseURL: baseURL,
            session: session,
            decoder: decoder,
            encoder: encoder,
            plugins: allPlugins,
            reachability: reachability
        )
    }
    
    // MARK: - 요청 메서드
    public func request<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        // 네트워크 요청 실행 및 응답 처리
        return try await performRequest(request)
    }
    
    public func upload<T: Decodable>(_ request: URLRequest, data: Data, mimeType: String, responseType: T.Type) async throws -> T {
        // URLRequest 복사
        var urlRequest = request
        
        // 업로드를 위한 설정
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(mimeType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data
        
        // 플러그인 적용 및 업로드 요청 실행
        try await applyPlugins(to: &urlRequest)
        let (responseData, response) = try await session.upload(for: urlRequest, from: data)
        
        // 응답 처리
        return try await processResponse(urlRequest, response, responseData)
    }
    
    // MARK: - 내부 메서드
    /// 네트워크 요청 실행 및 응답 처리를 위한 공통 메서드
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        // 플러그인 적용
        var urlRequest = request
        try await applyPlugins(to: &urlRequest)
        
        // 네트워크 요청 실행
        let (data, response) = try await session.data(for: urlRequest)
        
        // 응답 처리
        return try await processResponse(urlRequest, response, data)
    }
    
    /// 응답 처리를 위한 공통 메서드
    private func processResponse<T: Decodable>(_ request: URLRequest, _ response: URLResponse, _ data: Data) async throws -> T {
        // 응답 확인
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 응답 후 플러그인 실행
        try await plugins.asyncForEach { plugin in
            try await plugin.process(request, httpResponse, data)
        }
        
        // 상태 코드 확인
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        // 응답 데이터 디코딩
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// 플러그인 적용
    private func applyPlugins(to request: inout URLRequest) async throws {
        for plugin in plugins {
            try await plugin.prepare(&request)
        }
    }
}

// 배열에 대한 비동기 forEach 확장
extension Array {
    func asyncForEach(
        _ operation: @escaping (Element) async throws -> Void
    ) async throws {
        for element in self {
            try await operation(element)
        }
    }
} 
