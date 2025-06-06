import Foundation
import DomainModule

// 앱 환경 설정 열거형
public enum AppEnvironment {
    case production
    case test
}

@MainActor
public protocol AppDIContainerProtocol {
    func authDIContainer() -> AuthDIContainerProtocol
    func accountDIContainer() -> AccountDIContainerProtocol
    func transferDIContainer() -> TransferDIContainerProtocol
    func settingsDIContainer() -> SettingsDIContainerProtocol
    
    // 테스트 관련 속성
    var environment: AppEnvironment { get }
}

// MARK: - Auth 모듈 DIContainer 프로토콜
@MainActor
public protocol AuthDIContainerProtocol {
    
    // ViewModels
    func makeLoginViewModel(
        onLoginSuccess: @escaping () -> Void,
        onRegisterTapped: @escaping () -> Void
    ) -> any AsyncViewModel
    
    func makePINLoginViewModel(
        onLoginSuccess: @escaping () -> Void
    ) -> any AsyncViewModel
    
    func makePINSetupViewModel(
        onSetupComplete: @escaping () -> Void
    ) -> any AsyncViewModel
    
    func makeRegisterViewModel(
        onRegisterSuccess: @escaping () -> Void,
        onBackTapped: @escaping () -> Void
    ) -> any AsyncViewModel
    
    // UseCases
    func makeCheckPINExistsUseCase() -> CheckPINExistsUseCaseProtocol
}

@MainActor
// MARK: - 설정 모듈 DIContainer 프로토콜
public protocol SettingsDIContainerProtocol {
    // ViewModels
    func makeSecuritySettingsViewModel(
        onPINSetupTapped: (() -> Void)?,
        onPINChangeTapped: (() -> Void)?
    ) -> any AsyncViewModel
    
    func makePINSetupViewModel(
        onSetupComplete: @escaping () -> Void
    ) -> any AsyncViewModel
    
    // UseCases
    func makeCheckPINExistsUseCase() -> CheckPINExistsUseCaseProtocol
    
    // AuthDIContainer 접근
    func authDIContainer() -> AuthDIContainerProtocol
}

@MainActor
public protocol AccountDIContainerProtocol {
    func makeAccountListViewModel() -> any AsyncViewModel
    func makeAccountDetailViewModel(accountId: String) -> any AsyncViewModel
}

/// 송금 모듈 DI 컨테이너 인터페이스
@MainActor
public protocol TransferDIContainerProtocol {
    /// 송금 금액 입력 화면 뷰모델 생성
    /// - Parameter accountId: 출금 계좌 ID
    /// - Returns: 송금 금액 입력 화면 뷰모델
    func makeTransferAmountViewModel(accountId: String) -> any AsyncViewModel
    
    /// 송금 확인 화면 뷰모델 생성
    /// - Parameters:
    ///   - sourceAccountId: 출금 계좌 ID
    ///   - amount: 송금 금액
    ///   - receiverAccount: 수취 계좌 정보
    /// - Returns: 송금 확인 화면 뷰모델
    func makeTransferConfirmViewModel(
        sourceAccountId: String,
        amount: Double,
        receiverAccount: BankAccount
    ) -> any AsyncViewModel
    
    /// 송금 결과 화면 뷰모델 생성
    /// - Parameter success: 송금 성공 여부
    /// - Returns: 송금 결과 화면 뷰모델
    func makeTransferResultViewModel(success: Bool) -> any AsyncViewModel
} 
