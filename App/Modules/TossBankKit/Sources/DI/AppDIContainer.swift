import Foundation
import NetworkModule

/// 앱 의존성 주입 컨테이너 프로토콜
public protocol AppDIContainerProtocol {
    func authDIContainer() -> AuthDIContainerProtocol
    func accountDIContainer() -> AccountDIContainerProtocol
    func transferDIContainer() -> TransferDIContainerProtocol
}

/// 인증 의존성 주입 컨테이너 프로토콜
public protocol AuthDIContainerProtocol {
    var authRepository: AuthRepositoryProtocol { get }
}

/// 계좌 의존성 주입 컨테이너 프로토콜
public protocol AccountDIContainerProtocol {
    var accountRepository: AccountRepositoryProtocol { get }
}

/// 송금 의존성 주입 컨테이너 프로토콜
public protocol TransferDIContainerProtocol {
    var accountRepository: AccountRepositoryProtocol { get }
}

/// 앱 의존성 주입 컨테이너 구현
public final class AppDIContainer: AppDIContainerProtocol {
    // MARK: - Network
    lazy var networkService: NetworkServiceProtocol = {
        let config = APIConfiguration(
            baseURL: URL(string: "https://api.example.com")!,
            headers: ["Content-Type": "application/json"]
        )
        
        // 인터셉터(플러그인) 구성
        var plugins: [NetworkPlugin] = [
            ConnectivityInterceptor(),
            AuthInterceptor { [weak self] in
                return "sample-auth-token"
            }
        ]
        
        #if DEBUG
        plugins.append(LoggingInterceptor(logLevel: .body))
        #endif
        
        plugins.append(CacheInterceptor())
        plugins.append(TimeoutInterceptor(timeout: 15.0))
        
        return NetworkService(
            session: .shared,
            decoder: JSONDecoder(),
            configuration: config,
            plugins: plugins
        )
    }()
    
    // MARK: - Repositories
    lazy var authRepository: AuthRepositoryProtocol = {
        return AuthRepository(networkService: networkService)
    }()
    
    lazy var accountRepository: AccountRepositoryProtocol = {
        do {
            return try AccountRepository()
        } catch {
            fatalError("Failed to initialize AccountRepository: \(error)")
        }
    }()
    
    // MARK: - DIContainers
    public func authDIContainer() -> AuthDIContainerProtocol {
        return AuthDIContainer(authRepository: authRepository)
    }
    
    public func accountDIContainer() -> AccountDIContainerProtocol {
        return AccountDIContainer(accountRepository: accountRepository)
    }
    
    public func transferDIContainer() -> TransferDIContainerProtocol {
        return TransferDIContainer(accountRepository: accountRepository)
    }
    
    // MARK: - Initialization
    public init() {}
}

/// 인증 의존성 주입 컨테이너 구현
public final class AuthDIContainer: AuthDIContainerProtocol {
    public let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
}

/// 계좌 의존성 주입 컨테이너 구현
public final class AccountDIContainer: AccountDIContainerProtocol {
    public let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
}

/// 송금 의존성 주입 컨테이너 구현
public final class TransferDIContainer: TransferDIContainerProtocol {
    public let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
}

/// 인증 Repository 프로토콜
public protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> String
    func register(username: String, password: String, email: String) async throws -> Bool
    func validateToken(_ token: String) async throws -> Bool
}

/// 인증 Repository 구현
public class AuthRepository: AuthRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func login(username: String, password: String) async throws -> String {
        let endpoint = AuthEndpoint.login(username: username, password: password)
        let response: LoginResponse = try await networkService.request(endpoint)
        return response.token
    }
    
    public func register(username: String, password: String, email: String) async throws -> Bool {
        let endpoint = AuthEndpoint.register(username: username, password: password, email: email)
        let _: RegisterResponse = try await networkService.request(endpoint)
        return true
    }
    
    public func validateToken(_ token: String) async throws -> Bool {
        let endpoint = AuthEndpoint.validateToken(token: token)
        let response: ValidateTokenResponse = try await networkService.request(endpoint)
        return response.isValid
    }
}

/// 인증 관련 API 엔드포인트
enum AuthEndpoint: APIEndpoint {
    case login(username: String, password: String)
    case register(username: String, password: String, email: String)
    case validateToken(token: String)
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .register:
            return "/auth/register"
        case .validateToken:
            return "/auth/validate"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register:
            return .post
        case .validateToken:
            return .get
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .validateToken(let token):
            return ["token": token]
        default:
            return nil
        }
    }
    
    var bodyParameters: [String: Any]? {
        switch self {
        case .login(let username, let password):
            return ["username": username, "password": password]
        case .register(let username, let password, let email):
            return ["username": username, "password": password, "email": email]
        case .validateToken:
            return nil
        }
    }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        let endpoint = BaseAPIEndpoint(
            path: path,
            method: method,
            queryParameters: queryParameters,
            bodyParameters: bodyParameters
        )
        return try endpoint.asURLRequest(baseURL: baseURL)
    }
}

// 응답 모델
struct LoginResponse: Decodable {
    let token: String
    let expiresAt: Date
}

struct RegisterResponse: Decodable {
    let success: Bool
    let userId: String
}

struct ValidateTokenResponse: Decodable {
    let isValid: Bool
    let expiresAt: Date?
} 
