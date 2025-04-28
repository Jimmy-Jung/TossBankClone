//
//  ResetPasswordViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SharedModule
import DomainModule
import Combine

final class ResetPasswordViewModel: AsyncViewModel {
    // MARK: - Enums
    enum Input {
        case sendResetRequest
        case backTapped
        case dismissError
        case updateEmail(String)
    }
    
    enum Action {
        case performReset
        case navigateBack
        case handleDismissError
        case updateEmailField(String)
        case resetSuccess
    }
    
    // MARK: - Properties
    @Published var email: String = ""
    @Published var isLoading: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""
    
    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol
    private let onResetSent: () -> Void
    private let onBackTapped: () -> Void
    
    // MARK: - Initializer
    init(
        resetPasswordUseCase: ResetPasswordUseCaseProtocol,
        onResetSent: @escaping () -> Void,
        onBackTapped: @escaping () -> Void
    ) {
        self.resetPasswordUseCase = resetPasswordUseCase
        self.onResetSent = onResetSent
        self.onBackTapped = onBackTapped
    }
    
    // MARK: - AsyncViewModel
    func transform(_ input: Input) async -> [Action] {
        switch input {
        case .sendResetRequest:
            return [.performReset]
        case .backTapped:
            return [.navigateBack]
        case .dismissError:
            return [.handleDismissError]
        case .updateEmail(let email):
            return [.updateEmailField(email)]
        }
    }
    
    func perform(_ action: Action) async throws {
        switch action {
        case .performReset:
            await sendResetRequest()
        case .navigateBack:
            onBackTapped()
        case .handleDismissError:
            showErrorAlert = false
        case .updateEmailField(let email):
            self.email = email
        case .resetSuccess:
            onResetSent()
        }
    }
    
    func handleError(_ error: Error) async {
        if let entityError = error as? EntityError {
            await handleEntityError(entityError)
        } else {
            showError("예상치 못한 오류가 발생했습니다.")
        }
    }
    
    // MARK: - Private Methods
    private func sendResetRequest() async {
        do {
            // 이메일 검증
            guard !email.isEmpty else {
                showError("이메일을 입력해 주세요.")
                return
            }
            
            guard isValidEmail(email) else {
                showError("유효한 이메일 형식이 아닙니다.")
                return
            }
            
            await MainActor.run {
                isLoading = true
            }
            
            let result = await resetPasswordUseCase.execute(email: email)
            
            await MainActor.run {
                isLoading = false
                
                switch result {
                case .success:
                    onResetSent()
                case .failure(let error):
                    Task {
                        await handleError(error)
                    }
                }
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
    
    private func handleEntityError(_ error: EntityError) async {
        switch error {
        case .notFound:
            showError("해당 이메일로 등록된 계정을 찾을 수 없습니다.")
        case .networkError:
            showError("네트워크 연결을 확인해 주세요.")
        case .serverError:
            showError("서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.")
        case .validationError:
            showError("유효한 이메일 형식이 아닙니다.")
        case .invalidInput:
            showError("입력 정보가 올바르지 않습니다.")
        case .accessDenied:
            showError("접근이 거부되었습니다.")
        case .repositoryError(let underlyingError):
            showError("오류가 발생했습니다: \(underlyingError.localizedDescription)")
        case .unexpectedError(let underlyingError):
            showError("예상치 못한 오류가 발생했습니다: \(underlyingError.localizedDescription)")
        case .invalidData:
            showError("유효하지 않은 데이터입니다.")
        case .limitExceeded:
            showError("요청 제한을 초과했습니다.")
        case .insufficientFunds:
            showError("잔액이 부족합니다.")
        case .duplicateItem:
            showError("중복된 항목이 존재합니다.")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorAlert = true
    }
} 
