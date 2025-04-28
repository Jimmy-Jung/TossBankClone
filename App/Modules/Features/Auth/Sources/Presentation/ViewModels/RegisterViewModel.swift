//
//  RegisterViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SharedModule
import DomainModule
import Combine

final class RegisterViewModel: AsyncViewModel {
    // MARK: - Enums
    enum InputField {
        case email
        case password
        case confirmPassword
        case name
        case phoneNumber
    }
    
    enum ValidationError: Error, LocalizedError {
        case emptyField(InputField)
        case invalidEmail
        case invalidPassword
        case weakPassword
        case invalidPhoneNumber
        case passwordMismatch
        
        var errorDescription: String? {
            switch self {
            case .emptyField(let field):
                switch field {
                case .email: return "이메일을 입력해 주세요."
                case .password: return "비밀번호를 입력해 주세요."
                case .confirmPassword: return "비밀번호 확인을 입력해 주세요."
                case .name: return "이름을 입력해 주세요."
                case .phoneNumber: return "휴대폰 번호를 입력해 주세요."
                }
            case .invalidEmail: return "유효한 이메일 형식이 아닙니다."
            case .invalidPassword: return "비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다."
            case .weakPassword: return "더 강력한 비밀번호를 설정해 주세요."
            case .invalidPhoneNumber: return "유효한 휴대폰 번호 형식이 아닙니다."
            case .passwordMismatch: return "비밀번호가 일치하지 않습니다."
            }
        }
    }
    
    enum Input {
        case register
        case backTapped
        case dismissError
        case updateEmail(String)
        case updatePassword(String)
        case updateConfirmPassword(String)
        case updateName(String)
        case updatePhoneNumber(String)
    }
    
    enum Action {
        case performRegistration
        case navigateBack
        case handleDismissError
        case updateEmailField(String)
        case updatePasswordField(String)
        case updateConfirmPasswordField(String)
        case updateNameField(String)
        case updatePhoneNumberField(String)
    }
    
    // MARK: - Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var name: String = ""
    @Published var phoneNumber: String = ""
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let registerUseCase: RegisterUseCaseProtocol
    private let onRegisterSuccess: () -> Void
    private let onBackTapped: () -> Void
    
    // MARK: - Initializer
    init(
        registerUseCase: RegisterUseCaseProtocol,
        onRegisterSuccess: @escaping () -> Void,
        onBackTapped: @escaping () -> Void
    ) {
        self.registerUseCase = registerUseCase
        self.onRegisterSuccess = onRegisterSuccess
        self.onBackTapped = onBackTapped
    }
    
    // MARK: - AsyncViewModel
    func transform(_ input: Input) async -> [Action] {
        switch input {
        case .register:
            return [.performRegistration]
        case .backTapped:
            return [.navigateBack]
        case .dismissError:
            return [.handleDismissError]
        case .updateEmail(let email):
            return [.updateEmailField(email)]
        case .updatePassword(let password):
            return [.updatePasswordField(password)]
        case .updateConfirmPassword(let confirmPassword):
            return [.updateConfirmPasswordField(confirmPassword)]
        case .updateName(let name):
            return [.updateNameField(name)]
        case .updatePhoneNumber(let number):
            return [.updatePhoneNumberField(number)]
        }
    }
    
    func perform(_ action: Action) async throws {
        switch action {
        case .performRegistration:
            await performRegistration()
        case .navigateBack:
            onBackTapped()
        case .handleDismissError:
            showErrorAlert = false
        case .updateEmailField(let email):
            self.email = email
        case .updatePasswordField(let password):
            self.password = password
        case .updateConfirmPasswordField(let confirmPassword):
            self.confirmPassword = confirmPassword
        case .updateNameField(let name):
            self.name = name
        case .updatePhoneNumberField(let number):
            self.phoneNumber = number
        }
    }
    
    func handleError(_ error: Error) async {
        if let entityError = error as? EntityError {
            showError(message: "오류가 발생했습니다: \(entityError.localizedDescription)")
        } else if let validationError = error as? ValidationError {
            showError(message: validationError.errorDescription ?? "유효성 검사 오류가 발생했습니다.")
        } else {
            showError(message: "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    // MARK: - Private Methods
    private func performRegistration() async {
        do {
            try validateInputs()
            
            await MainActor.run {
                isLoading = true
            }
            
            let result = await registerUseCase.execute(
                email: email,
                password: password,
                fullName: name,
                phoneNumber: phoneNumber
            )
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    onRegisterSuccess()
                case .failure(let error):
                    Task {
                        await handleError(error)
                    }
                }
            }
        } catch {
            await handleError(error)
        }
    }
    
    private func validateInputs() throws {
        // 빈 필드 확인
        if email.isEmpty { throw ValidationError.emptyField(.email) }
        if password.isEmpty { throw ValidationError.emptyField(.password) }
        if confirmPassword.isEmpty { throw ValidationError.emptyField(.confirmPassword) }
        if name.isEmpty { throw ValidationError.emptyField(.name) }
        if phoneNumber.isEmpty { throw ValidationError.emptyField(.phoneNumber) }
        
        // 이메일 유효성 검사
        if !isValidEmail(email) { throw ValidationError.invalidEmail }
        
        // 비밀번호 유효성 검사
        if !isValidPassword(password) { throw ValidationError.invalidPassword }
        
        // 비밀번호 일치 확인
        if password != confirmPassword { throw ValidationError.passwordMismatch }
        
        // 휴대폰 번호 유효성 검사
        if !isValidPhoneNumber(phoneNumber) { throw ValidationError.invalidPhoneNumber }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // 8자 이상, 영문자, 숫자, 특수 문자 포함
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPredicate.evaluate(with: password)
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegEx = "^01([0|1|6|7|8|9])-?([0-9]{3,4})-?([0-9]{4})$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegEx)
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    private func showError(message: String) {
        errorMessage = message
        showErrorAlert = true
    }
} 
