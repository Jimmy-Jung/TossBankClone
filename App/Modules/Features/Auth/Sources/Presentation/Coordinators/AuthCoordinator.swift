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
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        viewController.title = "로그인"
        
        // 임시 텍스트 레이블 추가
        let label = UILabel()
        label.text = "로그인 화면"
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showRegister() {
        // 회원가입 화면 구현 코드가 추가될 예정
    }
} 
