//
//  AuthCoordinator.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import UIKit
import SwiftUI
import AuthenticationModule
import SharedModule

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
        showLogin()
    }
    
    private func showLogin() {
        // 로그인 뷰모델 생성
        let authManager = AuthenticationManager.shared
        let viewModel = LoginViewModel(
            authenticationManager: authManager,
            onLoginSuccess: { [weak self] in
                // 로그인 성공 시 delegate 호출
                self?.delegate?.authCoordinatorDidFinish()
            },
            onRegisterTapped: { [weak self] in
                // 회원가입 화면으로 이동
                self?.showRegister()
            }
        )
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let loginView = LoginView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: loginView)
        
        // 네비게이션 바 숨기기
        viewController.navigationItem.hidesBackButton = true
        navigationController.isNavigationBarHidden = true
        
        navigationController.viewControllers = [viewController]
    }
    
    private func showRegister() {
        // 회원가입 화면 구현 (실제 앱에서는 구현 필요)
        let viewController = UIViewController()
        viewController.view.backgroundColor = .white
        viewController.title = "회원가입"
        
        // 임시 텍스트 레이블 추가
        let label = UILabel()
        label.text = "회원가입 화면"
        label.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])
        
        // 네비게이션 바 표시
        navigationController.isNavigationBarHidden = false
        
        navigationController.pushViewController(viewController, animated: true)
    }
} 
