import Foundation
import CoordinatorModule
import DomainModule
import DataModule
import AuthenticationModule
import NetworkModule

/// 앱 DI 컨테이너 구현
public final class AppDIContainer: AppDIContainerProtocol {
    // MARK: - 싱글톤 인스턴스
    public static let shared = AppDIContainer()
    
    // MARK: - 프로퍼티
    private let accountRepository: AccountRepositoryProtocol
    private let authenticationManager: AuthenticationManager
    private let networkService: NetworkServiceProtocol
    
    // MARK: - 생성자
    private init() {
        // 네트워크 서비스 초기화
        let baseURL = URL(string: "https://api.tossbank.com")!
        self.networkService = NetworkService(
            baseURL: baseURL,
            authTokenProvider: { UserDefaults.standard.string(forKey: "authToken") }
        )
        
        // 인증 관리자 초기화
        self.authenticationManager = AuthenticationManager.shared
        
        // 계정 리포지토리 초기화
        do {
            self.accountRepository = try AccountRepositoryImpl()
        } catch {
            fatalError("계정 리포지토리 초기화 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - DIContainer 팩토리 메서드
    public func authDIContainer() -> AuthDIContainerProtocol {
        return AuthDIContainer(authenticationManager: authenticationManager)
    }
    
    public func accountDIContainer() -> AccountDIContainerProtocol {
        return AccountDIContainer(accountRepository: accountRepository)
    }
    
    public func transferDIContainer() -> TransferDIContainerProtocol {
        return TransferDIContainer(accountRepository: accountRepository)
    }
}

// MARK: - Auth DI Container
final class AuthDIContainer: AuthDIContainerProtocol {
    private let authenticationManager: AuthenticationManager
    
    init(authenticationManager: AuthenticationManager) {
        self.authenticationManager = authenticationManager
    }
}

// MARK: - Account DI Container
final class AccountDIContainer: AccountDIContainerProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    func makeFetchAccountsUseCase() -> FetchAccountsUseCase {
        return FetchAccountsUseCase(accountRepository: accountRepository)
    }
    
    func makeFetchAccountDetailsUseCase() -> FetchAccountDetailsUseCase {
        return FetchAccountDetailsUseCase(accountRepository: accountRepository)
    }
}

// MARK: - Transfer DI Container
final class TransferDIContainer: TransferDIContainerProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    func makeAddTransactionUseCase() -> AddTransactionUseCase {
        return AddTransactionUseCase(accountRepository: accountRepository)
    }
}