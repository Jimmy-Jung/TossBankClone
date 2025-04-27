import Foundation

// 앱 환경 설정 열거형
public enum AppEnvironment {
    case production
    case test
}

@MainActor
public protocol AppDIContainerProtocol: AnyObject {
    func authDIContainer() -> AuthDIContainerProtocol
    func accountDIContainer() -> AccountDIContainerProtocol
    func transferDIContainer() -> TransferDIContainerProtocol
    func settingsDIContainer() -> SettingsDIContainerProtocol
    
    // 테스트 관련 속성
    var environment: AppEnvironment { get }
}

@MainActor
public protocol AuthDIContainerProtocol: AnyObject {}
@MainActor
public protocol TransferDIContainerProtocol: AnyObject {}
@MainActor
public protocol SettingsDIContainerProtocol: AnyObject {}
@MainActor
public protocol AccountDIContainerProtocol: AnyObject {
    func makeAccountListViewModel() -> any AsyncViewModel
    func makeAccountDetailViewModel(accountId: String) -> any AsyncViewModel
}
