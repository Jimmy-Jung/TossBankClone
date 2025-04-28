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
import DesignSystem
import DomainModule

/// 인증 코디네이터 구현
public final class AuthCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: AuthDIContainerProtocol
    private var authenticationManager: AuthenticationManagerProtocol = AuthenticationManager.shared
    
    public weak var delegate: AuthCoordinatorDelegate?
    
    public init(
        navigationController: UINavigationController,
        diContainer: AuthDIContainerProtocol
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        showLogin()
    }
    
    private func showLogin() {
        // 1. 로그인 상태 확인
        let isLoggedIn = authenticationManager.isAuthenticated
        print("👤 사용자 로그인 상태: \(isLoggedIn ? "로그인됨" : "로그아웃됨")")
        
        if isLoggedIn {
            // 2. PIN 설정 여부 확인
            let checkPINExistsUseCase = diContainer.makeCheckPINExistsUseCase()
            let isPINSet = checkPINExistsUseCase.execute()
            print("🔐 PIN 설정 상태: \(isPINSet ? "설정됨" : "설정되지 않음")")
            
            if isPINSet {
                // 3. PIN 설정되어 있으면 PIN 로그인 화면 표시
                showPINLogin()
            } else {
                // 4. PIN 설정되어 있지 않으면 PIN 설정 화면으로 이동
                showPINSetup()
            }
        } else {
            // 5. 로그인되지 않은 경우 이메일/패스워드 로그인 화면 표시
            showLoginWithViewModel()
        }
    }
    
    private func showPINLogin() {
        let pinLoginViewModel = diContainer.makePINLoginViewModel { [weak self] in
            // 로그인 성공 시 delegate 호출
            self?.delegate?.authCoordinatorDidFinish()
        }
        
        let pinLoginView = PINLoginView(viewModel: pinLoginViewModel as? PINLoginViewModel)
        
        let viewController = UIHostingController(rootView: pinLoginView)
        viewController.navigationItem.hidesBackButton = true
        navigationController.isNavigationBarHidden = true
        
        navigationController.viewControllers = [viewController]
    }
    
    private func showPINSetup() {
        let pinSetupViewModel = diContainer.makePINSetupViewModel { [weak self] in
            // PIN 설정 완료 시 delegate 호출
            self?.delegate?.authCoordinatorDidFinish()
        }
        
        let pinSetupView = PINSetupView(viewModel: pinSetupViewModel as? PINSetupViewModel)
        
        let viewController = UIHostingController(rootView: pinSetupView)
        viewController.navigationItem.hidesBackButton = true
        navigationController.isNavigationBarHidden = true
        
        navigationController.viewControllers = [viewController]
    }
    
    private func showLoginWithViewModel() {
        // 로그인 뷰모델 생성
        guard let loginViewModel = diContainer.makeLoginViewModel(
            onLoginSuccess: { [weak self] in
                // 로그인 성공 시 PIN 설정 확인
                guard let self = self else { return }
                
                let checkPINExistsUseCase = self.diContainer.makeCheckPINExistsUseCase()
                let isPINSet = checkPINExistsUseCase.execute()
                
                print("🔐 로그인 성공 후 PIN 설정 상태: \(isPINSet ? "설정됨" : "설정되지 않음")")
                
                if !isPINSet {
                    // PIN이 설정되어 있지 않으면 PIN 설정 화면으로 이동
                    self.showPINSetup()
                } else {
                    // PIN이 이미 설정되어 있으면 메인 화면으로 이동
                    self.delegate?.authCoordinatorDidFinish()
                }
            },
            onRegisterTapped: { [weak self] in
                // 회원가입 화면으로 이동
                self?.showRegister()
            }
        ) as? LoginViewModel else {
            return
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let loginView = LoginView(viewModel: loginViewModel)
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
        
        // 회원가입 완료 버튼 추가 (실제 구현에서는 회원가입 양식 제출 후 로직으로 변경)
        let registerButton = UIButton(type: .system)
        registerButton.setTitle("회원가입 완료", for: .normal)
        registerButton.addTarget(self, action: #selector(registerComplete), for: .touchUpInside)
        registerButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(registerButton)
        
        NSLayoutConstraint.activate([
            registerButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor)
        ])
        
        // 네비게이션 바 표시
        navigationController.isNavigationBarHidden = false
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    @objc private func registerComplete() {
        // 회원가입 성공 후 PIN 설정으로 이동
        navigationController.popViewController(animated: true)
        
        // 지연을 주어 애니메이션이 완료된 후 PIN 설정 화면 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.showPINSetup()
        }
    }
} 
