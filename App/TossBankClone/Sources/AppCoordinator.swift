//
//  AppDIContainer.swift
//  TossBackClone
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import UIKit
import DomainModule
import AuthFeature
import AccountFeature
import SettingsFeature
import TransferFeature
import NetworkModule
import SharedModule
import AuthenticationModule

final class AppDIContainer: AppDIContainerProtocol {
    
    // MARK: - 속성
    public let environment: AppEnvironment
    public let networkService: NetworkServiceProtocol
    private let authenticationManager: AuthenticationManagerProtocol
    private let baseURL: URL
    
    // MARK: - 초기화
    init(
        environment: AppEnvironment = .test,
        baseURL: URL = URL(string: "https://api.tossbank.com")!
    ) {
        self.environment = environment
        self.baseURL = baseURL
        
        // 환경에 따른 초기화
        switch environment {
        case .production:
            // 프로덕션 환경에서는 실제 서비스 사용
            self.networkService = NetworkService(baseURL: baseURL)
            self.authenticationManager = AuthenticationManager.shared
            
        case .test:
            // 테스트 환경에서는 모의 서비스 사용
            self.networkService = MockNetworkService()
            self.authenticationManager = AuthenticationManager.shared
        }
    }

    
    // MARK: - 하위 컨테이너 팩토리 메서드
    
    func authDIContainer() -> AuthDIContainerProtocol {
        return AuthDIContainer(
            environment: environment,
            authenticationManager: authenticationManager,
            networkService: networkService
        )
    }
    
    func accountDIContainer() -> AccountDIContainerProtocol {
        return AccountDIContainer(
            environment: environment,
            networkService: networkService
        )
    }
    
    func transferDIContainer() -> TransferDIContainerProtocol {
        return TransferDIContainer(
            environment: environment,
            networkService: networkService
        )
    }
    
    func settingsDIContainer() -> SettingsDIContainerProtocol {
        return SettingsDIContainer(
            authenticationManager: authenticationManager,
            appDIContainer: self
        )
    }
}

/// 앱 코디네이터 구현
final class AppCoordinator: Coordinator {
    // MARK: - 속성
    private let window: UIWindow
    private let diContainer: AppDIContainerProtocol
    
    private var childCoordinators: [Coordinator] = []
    private var isLoggedIn: Bool = false
    
    // MARK: - 초기화
    init(window: UIWindow, diContainer: AppDIContainerProtocol) {
        self.window = window
        self.diContainer = diContainer
    }
    
    // MARK: - Coordinator 구현
    func start() {
        // 로그인 상태에 따라 적절한 화면 표시
        checkAuthenticationStatus()
    }
    
    // MARK: - 인증 상태 확인
    private func checkAuthenticationStatus() {
        // 실제 구현에서는 인증 서비스에서 로그인 상태를 가져와야 함
        // 여기서는 임시로 로그인 상태를 설정
        if isLoggedIn {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }
    
    // MARK: - 화면 흐름 메서드
    
    private func showAuthFlow() {
        // 인증 네비게이션 컨트롤러 생성
        let navigationController = UINavigationController()
        
        // 인증 코디네이터 생성 및 설정
        let authCoordinator = AuthCoordinator(
            navigationController: navigationController,
            diContainer: diContainer.authDIContainer()
        )
        authCoordinator.delegate = self
        
        // 코디네이터 시작
        addChildCoordinator(authCoordinator)
        authCoordinator.start()
        
        // 화면 표시
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func showMainFlow() {
        // 탭 바 컨트롤러 생성
        let tabBarController = UITabBarController()
        
        // 각 탭에 대한 코디네이터 생성 및 설정
        let controllers = [
            makeAccountTab(),
            makeTransferTab()
        ]
        
        tabBarController.viewControllers = controllers
        tabBarController.selectedIndex = 0
        
        // 화면 표시
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    private func makeAccountTab() -> UINavigationController {
        let navigationController = UINavigationController()
        let accountCoordinator = AccountCoordinator(
            navigationController: navigationController,
            diContainer: diContainer.accountDIContainer()
        )
        accountCoordinator.delegate = self
        
        // 코디네이터 시작
        addChildCoordinator(accountCoordinator)
        accountCoordinator.start()
        
        return navigationController
    }
    
    private func makeTransferTab() -> UINavigationController {
        let navigationController = UINavigationController()
        
        // TransferCoordinator는 보통 계좌 화면에서 시작되므로 여기서는 임시 화면 표시
        let placeholderVC = UIViewController()
        placeholderVC.view.backgroundColor = .white
        placeholderVC.title = "빠른 송금"
        placeholderVC.tabBarItem = UITabBarItem(
            title: "송금",
            image: UIImage(systemName: "arrow.right"),
            selectedImage: UIImage(systemName: "arrow.right.fill")
        )
        
        navigationController.viewControllers = [placeholderVC]
        return navigationController
    }
    
    private func showTransferFlow(fromAccountId: String) {
        // 송금 화면용 네비게이션 컨트롤러 생성
        let navigationController = UINavigationController()
        
        // 송금 코디네이터 생성 및 설정
        let transferCoordinator = TransferCoordinator(
            navigationController: navigationController,
            diContainer: diContainer.transferDIContainer(),
            sourceAccountId: fromAccountId
        )
        
        transferCoordinator.delegate = self
        
        // 코디네이터 시작
        addChildCoordinator(transferCoordinator)
        transferCoordinator.start()
        
        // 송금할 계좌 ID 정보는 다른 방식으로 전달해야 함
        // 예: TransferCoordinator에 별도 메서드 추가 필요
        
        // 모달로 표시
        if let rootViewController = window.rootViewController {
            navigationController.modalPresentationStyle = .fullScreen
            rootViewController.present(navigationController, animated: true)
        }
    }
    
    private func showSettingsFlow() {
        // 설정 화면용 네비게이션 컨트롤러 생성
        let navigationController = UINavigationController()
        
        // 설정 코디네이터 생성 및 설정
        let settingsCoordinator = SettingsCoordinator(
            navigationController: navigationController,
            diContainer: diContainer.settingsDIContainer()
        )
        settingsCoordinator.delegate = self
        
        // 코디네이터 시작
        addChildCoordinator(settingsCoordinator)
        settingsCoordinator.start()
        
        // 모달로 표시
        if let rootViewController = window.rootViewController {
            navigationController.modalPresentationStyle = .formSheet
            rootViewController.present(navigationController, animated: true)
        }
    }
    
    // MARK: - 코디네이터 관리 메서드
    
    private func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    private func removeChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}

// MARK: - AuthCoordinatorDelegate 구현
extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish() {
        isLoggedIn = true
        
        // Auth 코디네이터 참조 제거
        if let authCoordinator = childCoordinators.first(where: { $0 is AuthCoordinator }) {
            removeChildCoordinator(authCoordinator)
        }
        
        // 메인 화면으로 전환
        showMainFlow()
    }
}

// MARK: - AccountCoordinatorDelegate 구현
extension AppCoordinator: AccountCoordinatorDelegate {
    func accountCoordinatorDidRequestTransfer(fromAccountId: String) {
        showTransferFlow(fromAccountId: fromAccountId)
    }
    
    func accountCoordinatorDidRequestSettings() {
        showSettingsFlow()
    }
}

// MARK: - TransferCoordinatorDelegate 구현
extension AppCoordinator: TransferCoordinatorDelegate {
    func transferCoordinatorDidFinish() {
        // 송금 완료 후 모달 닫기
        if let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: true) { [weak self] in
                // Transfer 코디네이터 참조 제거
                if let transferCoordinator = self?.childCoordinators.first(where: { $0 is TransferCoordinator }) {
                    self?.removeChildCoordinator(transferCoordinator)
                }
            }
        }
    }
    
    func transferCoordinatorDidCancel() {
        // 송금 취소 후 모달 닫기
        if let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: true) { [weak self] in
                // Transfer 코디네이터 참조 제거
                if let transferCoordinator = self?.childCoordinators.first(where: { $0 is TransferCoordinator }) {
                    self?.removeChildCoordinator(transferCoordinator)
                }
            }
        }
    }
}

// MARK: - SettingsCoordinatorDelegate 구현
extension AppCoordinator: SettingsCoordinatorDelegate {
    func settingsCoordinatorDidFinish() {
        // 설정 화면 닫기
        if let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: true) { [weak self] in
                // Settings 코디네이터 참조 제거
                if let settingsCoordinator = self?.childCoordinators.first(where: { $0 is SettingsCoordinator }) {
                    self?.removeChildCoordinator(settingsCoordinator)
                }
            }
        }
    }
    
    func settingsCoordinatorDidRequestLogout() {
        // 로그아웃 처리
        isLoggedIn = false
        
        // 설정 화면 닫기
        if let rootViewController = window.rootViewController {
            rootViewController.dismiss(animated: true) { [weak self] in
                // 모든 코디네이터 참조 제거
                self?.childCoordinators.removeAll()
                
                // 로그인 화면으로 전환
                self?.showAuthFlow()
            }
        }
    }
} 
