import UIKit
import SwiftUI
import TossBankKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // 앱 코디네이터 설정
        let appDIContainer = AppDIContainer()
        appCoordinator = AppCoordinator(window: window, diContainer: appDIContainer)
        appCoordinator?.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // 씬이 연결 해제될 때 호출
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 씬이 활성화될 때 호출
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // 씬이 비활성화될 때 호출
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // 앱이 포그라운드로 전환될 때 호출
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 백그라운드로 전환될 때 호출
    }
} 