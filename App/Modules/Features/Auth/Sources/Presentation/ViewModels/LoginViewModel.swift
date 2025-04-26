//
//  LoginViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import AuthenticationModule
import SharedModule

final class LoginViewModel: AsyncViewModel {
    enum Input {
        case login
        case showRegister
        case dismissError
    }
    
    enum Action {
        case performLogin
        case navigateToRegister
        case dismissErrorAlert
    }
    
    // 상태
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let authenticationManager: AuthenticationManagerProtocol
    private var onLoginSuccess: (() -> Void)?
    private var onRegisterTapped: (() -> Void)?
    
    init(authenticationManager: AuthenticationManagerProtocol,
         onLoginSuccess: @escaping () -> Void,
         onRegisterTapped: @escaping () -> Void) {
        self.authenticationManager = authenticationManager
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
        
        do {
            let success = try await authenticationManager.login(email: email, password: password)
            
            if success {
                onLoginSuccess?()
            } else {
                throw LoginError.invalidCredentials
            }
        } catch {
            throw error
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
}
