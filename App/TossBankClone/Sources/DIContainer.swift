import Foundation
import CoordinatorModule
import DomainModule
import DataModule
import AuthenticationModule
import NetworkModule

/// 앱의 DI 컨테이너 구현
final class AppDIContainer: AppDIContainerProtocol {
    
    // MARK: - 속성
    private let authenticationManager: AuthenticationManagerProtocol
    
    // MARK: - 초기화
    init() {
        // 인증 관리자 생성
        authenticationManager = AuthenticationManager()
    }
    
    // MARK: - 하위 컨테이너 팩토리 메서드
    
    func authDIContainer() -> AuthDIContainerProtocol {
        return AuthDIContainer(authenticationManager: authenticationManager)
    }
    
    func accountDIContainer() -> AccountDIContainerProtocol {
        return AccountDIContainer()
    }
    
    func transferDIContainer() -> TransferDIContainerProtocol {
        return TransferDIContainer()
    }
    
    func settingsDIContainer() -> SettingsDIContainerProtocol {
        return SettingsDIContainer()
    }
}

/// 인증 모듈 DI 컨테이너
final class AuthDIContainer: AuthDIContainerProtocol {
    // MARK: - 속성
    private let authenticationManager: AuthenticationManagerProtocol
    
    // MARK: - 초기화
    init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
}

/// 계좌 모듈 DI 컨테이너
final class AccountDIContainer: AccountDIContainerProtocol {
    // MARK: - 초기화
    init() {
        // 필요한 의존성 초기화
    }
}

/// 송금 모듈 DI 컨테이너
final class TransferDIContainer: TransferDIContainerProtocol {
    // MARK: - 초기화
    init() {
        // 필요한 의존성 초기화
    }
}

/// 설정 모듈 DI 컨테이너
final class SettingsDIContainer: SettingsDIContainerProtocol {
    // MARK: - 초기화
    init() {
        // 필요한 의존성 초기화
    }
}
