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

/// 앱 코디네이터 구현
public final class AppCoordinator: NSObject, Coordinator {
    private let window: UIWindow
    private let diContainer: AppDIContainerProtocol
    private var childCoordinators: [Coordinator] = []
    
    public weak var delegate: AppCoordinatorDelegate?
    
    public init(window: UIWindow, diContainer: AppDIContainerProtocol) {
        self.window = window
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        showMainOrAuth()
    }
    
    private func showMainOrAuth() {
        // TODO: 인증 상태 확인 로직 구현
        let isAuthenticated = false
        
        if isAuthenticated {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(
            navigationController: UINavigationController(),
            diContainer: diContainer.authDIContainer()
        )
        
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
        
        window.rootViewController = authCoordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    private func showMainFlow() {
        let tabBarCoordinator = MainTabBarCoordinator(
            tabBarController: UITabBarController(),
            diContainer: diContainer
        )
        
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        
        window.rootViewController = tabBarCoordinator.tabBarController
        window.makeKeyAndVisible()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    public func authCoordinatorDidFinish() {
        // 로그인 완료 후 메인 화면으로 전환
        showMainFlow()
    }
}

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

/// 메인 탭바 코디네이터 구현
public final class MainTabBarCoordinator: NSObject, Coordinator {
    public let tabBarController: UITabBarController
    private let diContainer: AppDIContainerProtocol
    private var childCoordinators: [Coordinator] = []
    
    public init(tabBarController: UITabBarController, diContainer: AppDIContainerProtocol) {
        self.tabBarController = tabBarController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        let homeCoordinator = HomeCoordinator(
            navigationController: UINavigationController(),
            diContainer: diContainer.accountDIContainer()
        )
        
        let transferCoordinator = TransferCoordinator(
            navigationController: UINavigationController(),
            diContainer: diContainer.transferDIContainer()
        )
        
        let settingsCoordinator = SettingsCoordinator(
            navigationController: UINavigationController()
        )
        
        childCoordinators = [homeCoordinator, transferCoordinator, settingsCoordinator]
        
        homeCoordinator.start()
        transferCoordinator.start()
        settingsCoordinator.start()
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            transferCoordinator.navigationController,
            settingsCoordinator.navigationController
        ]
        
        setupTabBarIcons()
    }
    
    private func setupTabBarIcons() {
        let homeItem = tabBarController.viewControllers?[0].tabBarItem
        homeItem?.title = "홈"
        homeItem?.image = UIImage(systemName: "house")
        homeItem?.selectedImage = UIImage(systemName: "house.fill")
        
        let transferItem = tabBarController.viewControllers?[1].tabBarItem
        transferItem?.title = "송금"
        transferItem?.image = UIImage(systemName: "arrow.left.arrow.right")
        transferItem?.selectedImage = UIImage(systemName: "arrow.left.arrow.right.circle.fill")
        
        let settingsItem = tabBarController.viewControllers?[2].tabBarItem
        settingsItem?.title = "설정"
        settingsItem?.image = UIImage(systemName: "gearshape")
        settingsItem?.selectedImage = UIImage(systemName: "gearshape.fill")
    }
}

/// 홈 코디네이터 구현
public final class HomeCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: AccountDIContainerProtocol
    
    public init(navigationController: UINavigationController, diContainer: AccountDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        // TODO: 홈 화면 구현 코드가 추가될 예정
    }
}

/// 송금 코디네이터 구현
public final class TransferCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: TransferDIContainerProtocol
    
    public init(navigationController: UINavigationController, diContainer: TransferDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        // TODO: 송금 화면 구현 코드가 추가될 예정
    }
}

/// 설정 코디네이터 구현
public final class SettingsCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    public func start() {
        // TODO: 설정 화면 구현 코드가 추가될 예정
    }
} 
