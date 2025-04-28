//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import SharedModule
import DomainModule

final class LoginViewModel: AsyncViewModel {
    enum Input {
        case login
        case showRegister
        case dismissError
        case updateEmail(String)
        case updatePassword(String)
    }
    
    enum Action {
        case performLogin
        case navigateToRegister
        case dismissErrorAlert
        case updateEmailField(String)
        case updatePasswordField(String)
    }
    
    // 상태
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let loginUseCase: LoginUseCaseProtocol
    private var onLoginSuccess: (() -> Void)?
    private var onRegisterTapped: (() -> Void)?
    
    init(
        loginUseCase: LoginUseCaseProtocol,
        onLoginSuccess: @escaping () -> Void,
        onRegisterTapped: @escaping () -> Void
    ) {
        self.loginUseCase = loginUseCase
        self.onLoginSuccess = onLoginSuccess
        self.onRegisterTapped = onRegisterTapped
    }
    
    func transform(_ input: Input) async -> [Action] {
        switch input {
        case .login:
            return [.performLogin]
        case .showRegister:
            return [.navigateToRegister]
        case .dismissError:
            return [.dismissErrorAlert]
        case .updateEmail(let email):
            return [.updateEmailField(email)]
        case .updatePassword(let password):
            return [.updatePasswordField(password)]
        }
    }
    
    
    func perform(_ action: Action) async throws {
        switch action {
        case .performLogin:
            try await performLogin()
        case .navigateToRegister:
            navigateToRegister()
        case .dismissErrorAlert:
            showErrorAlert = false
        case .updateEmailField(let email):
            self.email = email
        case .updatePasswordField(let password):
            self.password = password
        }
    }
    
    private func performLogin() async throws {
        guard isInputValid else {
            throw LoginError.invalidInput
        }
        
        isLoading = true
        defer {
            isLoading = false
        }
        
        let result = await loginUseCase.execute(email: email, password: password)
        
        switch result {
        case .success(let authResult):
            // 로그인 성공 처리
            
            // 1. 로그인 상태 및 사용자 정보 업데이트
            self.isLoading = false
            print("로그인 성공: 토큰 정보 저장됨 - 유효기간: \(authResult.token.expiresIn)초")
            
            // 2. 새 사용자인지 확인
            if authResult.isNewUser {
                print("새로운 사용자로 첫 로그인 성공")
                // 필요시 새 사용자 온보딩 플래그 설정
            }
            
            // 3. 사용자 정보 저장 (UserDefaults 등에 필요한 정보 캐싱)
            UserDefaults.standard.set(authResult.token.userId, forKey: "currentUserId")
            
            // 4. 마지막 로그인 시간 저장
            let now = Date()
            UserDefaults.standard.set(now.timeIntervalSince1970, forKey: "lastLoginTime")
            
            // 5. 로그인 콜백 호출
            onLoginSuccess?()
        case .failure(let error):
            // 에러 변환 및 처리
            switch error {
            case .invalidInput, .validationError:
                throw LoginError.invalidInput
            case .accessDenied:
                throw LoginError.invalidCredentials
            default:
                throw LoginError.serverError
            }
        }
    }
    
    private func navigateToRegister() {
        onRegisterTapped?()
    }
    
    func handleError(_ error: Error) async {
        if let loginError = error as? LoginError {
            switch loginError {
            case .invalidInput:
                errorMessage = "이메일과 비밀번호를 올바르게 입력해주세요."
            case .invalidCredentials:
                errorMessage = "이메일 또는 비밀번호가 잘못되었습니다."
            case .serverError:
                errorMessage = "서버 연결에 문제가 발생했습니다. 잠시 후 다시 시도해주세요."
            }
        } else {
            errorMessage = "로그인 중 오류가 발생했습니다: \(error.localizedDescription)"
        }
        
        showErrorAlert = true
    }
    
    var isInputValid: Bool {
        return !email.isEmpty && !password.isEmpty && email.contains("@")
    }
}

enum LoginError: Error {
    case invalidInput
    case invalidCredentials
    case serverError
}
