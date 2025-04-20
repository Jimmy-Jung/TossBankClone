import Foundation
import UIKit

/// 코디네이터 기본 프로토콜
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

/// DI 컨테이너 프로토콜 (임시)
public protocol AppDIContainerProtocol: AnyObject {
    func authDIContainer() -> AuthDIContainerProtocol
    func accountDIContainer() -> AccountDIContainerProtocol
    func transferDIContainer() -> TransferDIContainerProtocol
}

public protocol AuthDIContainerProtocol: AnyObject {}
public protocol AccountDIContainerProtocol: AnyObject {}
public protocol TransferDIContainerProtocol: AnyObject {} 