import Foundation
import UIKit
import CoordinatorModule
import DomainModule
import Features.Auth
import Features.Account
import Features.Settings

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