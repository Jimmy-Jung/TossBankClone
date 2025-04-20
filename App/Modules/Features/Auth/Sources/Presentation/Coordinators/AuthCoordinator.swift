import Foundation
import UIKit
import CoordinatorModule

/// 인증 코디네이터 구현
public final class AuthCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: AuthDIContainerProtocol
    
    public weak var delegate: AuthCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, diContainer: AuthDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        // TODO: 로그인 화면 표시 구현
        showLogin()
    }
    
    private func showLogin() {
        // 로그인 화면 구현 코드가 추가될 예정
    }
    
    private func showRegister() {
        // 회원가입 화면 구현 코드가 추가될 예정
    }
} 