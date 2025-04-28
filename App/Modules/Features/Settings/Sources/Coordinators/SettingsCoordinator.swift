//
//  SettingsCoordinator.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import UIKit
import SwiftUI
import SharedModule
import AuthFeature

/// 설정 코디네이터 구현
public final class SettingsCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: SettingsDIContainerProtocol
    
    public weak var delegate: SettingsCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, diContainer: SettingsDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    public func start() {
        showSettings()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showSettings() {
        // 설정 화면 뷰모델 생성
        let viewModel = SettingsViewModel()
        viewModel.onLogoutButtonTapped = { [weak self] in
            self?.delegate?.settingsCoordinatorDidRequestLogout()
        }
        viewModel.onNotificationCenterTapped = { [weak self] in
            self?.showNotificationCenter()
        }
        viewModel.onSecuritySettingsTapped = { [weak self] in
            self?.showSecuritySettings()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let settingsView = SettingsView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: settingsView)
        viewController.title = "설정"
        
        // 닫기 버튼 추가
        let closeButton = UIBarButtonItem(
            title: "닫기",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = closeButton
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showSecuritySettings() {
        // 보안 설정 화면 뷰모델 생성
        let viewModel = diContainer.makeSecuritySettingsViewModel(
            onPINSetupTapped: { [weak self] in
                self?.showPINSetup()
            },
            onPINChangeTapped: { [weak self] in
                self?.showPINChange()
            }
        )
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let securitySettingsView = SecuritySettingsView(viewModel: viewModel as? SecuritySettingsViewModel)
        let viewController = UIHostingController(rootView: securitySettingsView)
        viewController.title = "보안 설정"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showPINSetup() {
        // AuthModule의 PIN 설정 화면 사용
        // AuthDIContainer에 접근하기 위해 AppCoordinator에서 메서드 호출 필요
        let authDIContainer = diContainer.authDIContainer()
        
        let pinSetupViewModel = authDIContainer.makePINSetupViewModel(
            onSetupComplete: { [weak self] in
                // PIN 설정 완료 후 이전 화면으로 돌아가기
                self?.navigationController.popViewController(animated: true)
            }
        )
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let pinSetupView = PINSetupView(viewModel: pinSetupViewModel as? PINSetupViewModel)
        let viewController = UIHostingController(rootView: pinSetupView)
        viewController.title = "PIN 설정"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showPINChange() {
        // PIN 변경 화면은 기존 PIN 확인 후 새로운 PIN을 설정하는 과정
        // 현재는 단순히 PIN 설정화면으로 이동 (실제 구현에서는 별도 화면 필요)
        showPINSetup()
    }
    
    private func showNotificationCenter() {
        // 알림 센터 화면 전환
        let notificationCenterView = NotificationCenterView()
        let viewController = UIHostingController(rootView: notificationCenterView)
        viewController.title = "알림"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func closeButtonTapped() {
        delegate?.settingsCoordinatorDidFinish()
    }
}
