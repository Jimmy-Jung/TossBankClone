import Foundation
import UIKit

/// 코디네이터 기본 프로토콜
@MainActor
public protocol Coordinator: AnyObject {
    /// 코디네이터 시작 메서드
    func start()
}

/// 앱 코디네이터 델리게이트 프로토콜
public protocol AppCoordinatorDelegate: AnyObject {}

/// 인증 코디네이터 델리게이트 프로토콜
public protocol AuthCoordinatorDelegate: AnyObject {
    /// 인증 완료 알림 메서드
    func authCoordinatorDidFinish()
}

/// 계좌 코디네이터 델리게이트 프로토콜
public protocol AccountCoordinatorDelegate: AnyObject {
    /// 송금 기능 요청 메서드
    func accountCoordinatorDidRequestTransfer(fromAccountId: String)
    
    /// 설정 화면 요청 메서드
    func accountCoordinatorDidRequestSettings()
}

/// 송금 코디네이터 델리게이트 프로토콜
public protocol TransferCoordinatorDelegate: AnyObject {
    /// 송금 완료 알림 메서드
    func transferCoordinatorDidFinish()
    
    /// 송금 취소 알림 메서드
    func transferCoordinatorDidCancel()
}

/// 설정 코디네이터 델리게이트 프로토콜
public protocol SettingsCoordinatorDelegate: AnyObject {
    /// 설정 화면 닫기 알림 메서드
    func settingsCoordinatorDidFinish()
    
    /// 로그아웃 요청 메서드
    func settingsCoordinatorDidRequestLogout()
}

/// DI 컨테이너 프로토콜 (임시)
public protocol AppDIContainerProtocol: AnyObject {
    func authDIContainer() -> AuthDIContainerProtocol
    func accountDIContainer() -> AccountDIContainerProtocol
    func transferDIContainer() -> TransferDIContainerProtocol
    func settingsDIContainer() -> SettingsDIContainerProtocol
}

public protocol AuthDIContainerProtocol: AnyObject {}
public protocol AccountDIContainerProtocol: AnyObject {}
public protocol TransferDIContainerProtocol: AnyObject {}
public protocol SettingsDIContainerProtocol: AnyObject {} 
