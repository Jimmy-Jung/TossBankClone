import Foundation
import Network

// MARK: - 인증 인터셉터
public class AuthInterceptor: NetworkPlugin {
    private let tokenProvider: () -> String?
    
    public init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func prepare(_ request: inout URLRequest) async throws {
        // 토큰이 있는 경우에만 헤더에 추가
        if let token = tokenProvider() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 인증 관련 응답 처리 (예: 401 Unauthorized)
        if response.statusCode == 401 {
            // 토큰 만료 등의 처리가 필요한 경우
            throw NetworkError.unauthorized
        }
    }
}

// MARK: - 로깅 인터셉터
public class LoggingInterceptor: NetworkPlugin {
    private let logLevel: LogLevel
    
    public enum LogLevel {
        case none
        case basic // URL, 상태 코드만
        case headers // URL, 상태 코드, 헤더
        case body // URL, 상태 코드, 헤더, 바디
    }
    
    public init(logLevel: LogLevel = .basic) {
        self.logLevel = logLevel
    }
    
    public func prepare(_ request: inout URLRequest) async throws {
        guard logLevel != .none else { return }
        
        print("🌐 [REQUEST] \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        if logLevel == .headers || logLevel == .body {
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("📋 [HEADERS]")
                headers.forEach { print("   \($0.key): \($0.value)") }
            }
        }
        
        if logLevel == .body, let body = request.httpBody, let json = try? JSONSerialization.jsonObject(with: body) {
            print("📦 [BODY]")
            print("   \(json)")
        }
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        guard logLevel != .none else { return }
        
        print("📲 [RESPONSE] [\(response.statusCode)] \(request.url?.absoluteString ?? "")")
        
        if logLevel == .headers || logLevel == .body {
            print("📋 [HEADERS]")
            response.allHeaderFields.forEach { print("   \($0.key): \($0.value)") }
        }
        
        if logLevel == .body, !data.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: data) {
                print("📦 [BODY]")
                print("   \(json)")
            } else if let text = String(data: data, encoding: .utf8) {
                print("📦 [BODY]")
                print("   \(text)")
            }
        }
    }
}

// MARK: - 네트워크 연결 인터셉터
public class ConnectivityInterceptor: NetworkPlugin {
    private let monitor: NWPathMonitor
    private var isConnected: Bool = true
    
    public init() {
        self.monitor = NWPathMonitor()
        setupMonitor()
    }
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
    
    public func prepare(_ request: inout URLRequest) async throws {
        if !isConnected {
            throw NetworkError.noInternetConnection
        }
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 네트워크 응답 처리 시에는 특별한 동작이 필요 없음
    }
}

// MARK: - 캐시 인터셉터
public class CacheInterceptor: NetworkPlugin {
    private let cache: URLCache
    private let cachePolicy: URLRequest.CachePolicy
    
    public init(cache: URLCache = .shared, cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad) {
        self.cache = cache
        self.cachePolicy = cachePolicy
    }
    
    public func prepare(_ request: inout URLRequest) async throws {
        // GET 요청에만 캐싱 적용
        if request.httpMethod == "GET" {
            request.cachePolicy = cachePolicy
        }
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 캐시 가능한 응답만 저장
        if request.httpMethod == "GET" && (200...299).contains(response.statusCode) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
    }
}

// MARK: - 타임아웃 인터셉터
public class TimeoutInterceptor: NetworkPlugin {
    private let timeout: TimeInterval
    
    public init(timeout: TimeInterval = 30.0) {
        self.timeout = timeout
    }
    
    public func prepare(_ request: inout URLRequest) async throws {
        request.timeoutInterval = timeout
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 타임아웃은 요청 전에만 설정하므로, 응답 처리 시에는 특별한 작업이 필요 없음
    }
} 