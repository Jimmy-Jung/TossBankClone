//
//  PINSetupViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SharedModule
import DomainModule

public final class PINSetupViewModel: AsyncViewModel {
    // MARK: - Input & Action
    public enum Input {
        case viewDidLoad
        case numberTapped(Int)
        case deleteTapped
        case confirmPIN
    }
    
    public enum Action {
        case updatePIN(String)
        case verifyPIN
        case saveAndConfirmPIN
        case resetState
        case showError(String)
        case setupComplete
    }
    
    // MARK: - 상태 열거형
    public enum SetupState {
        case enterPIN
        case confirmPIN
        case success
        case error
    }
    
    // MARK: - 퍼블리셔
    @Published public var pin: String = ""
    @Published public var confirmPin: String = ""
    @Published public var currentState: SetupState = .enterPIN
    @Published public var errorMessage: String = ""
    @Published public var isError: Bool = false
    
    // MARK: - 의존성
    private let savePINUseCase: SavePINUseCaseProtocol
    private let onSetupComplete: () -> Void
    
    // MARK: - 계산 속성
    public var headerTitle: String {
        switch currentState {
        case .enterPIN:
            return "PIN 번호 설정"
        case .confirmPIN:
            return "PIN 번호 확인"
        case .success:
            return "PIN 설정 완료"
        case .error:
            return "오류"
        }
    }
    
    public var headerSubtitle: String {
        switch currentState {
        case .enterPIN:
            return "6자리 PIN 번호를 입력해주세요"
        case .confirmPIN:
            return "PIN 번호를 다시 한번 입력해주세요"
        case .success:
            return "PIN 번호가 성공적으로 설정되었습니다"
        case .error:
            return errorMessage
        }
    }
    
    public var currentPINDisplay: String {
        return currentState == .enterPIN ? pin : confirmPin
    }
    
    // MARK: - 생성자
    public init(
        savePINUseCase: SavePINUseCaseProtocol,
        onSetupComplete: @escaping () -> Void
    ) {
        self.savePINUseCase = savePINUseCase
        self.onSetupComplete = onSetupComplete
    }
    
    // MARK: - AsyncViewModel 구현
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return []
            
        case .numberTapped(let number):
            return handleNumberTapped(number)
            
        case .deleteTapped:
            return handleDeleteTapped()
            
        case .confirmPIN:
            return [.verifyPIN]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .updatePIN(let newPin):
            updatePIN(newPin)
        case .verifyPIN:
            try await verifyPIN()
        case .saveAndConfirmPIN:
            try await saveAndConfirmPIN()
        case .resetState:
            resetState()
        case .showError(let message):
            showError(message: message)
        case .setupComplete:
            completeSetup()
        }
    }
    
    public func handleError(_ error: Error) async {
        showError(message: "오류가 발생했습니다: \(error.localizedDescription)")
    }
    
    // MARK: - 내부 메서드
    private func handleNumberTapped(_ number: Int) -> [Action] {
        guard !isError else {
            return [.resetState]
        }
        
        if currentState == .enterPIN {
            guard pin.count < 6 else { return [] }
            return [.updatePIN(pin + "\(number)")]
        } else {
            guard confirmPin.count < 6 else { return [] }
            return [.updatePIN(confirmPin + "\(number)")]
        }
    }
    
    private func handleDeleteTapped() -> [Action] {
        guard !isError else {
            return [.resetState]
        }
        
        if currentState == .enterPIN {
            guard !pin.isEmpty else { return [] }
            return [.updatePIN(String(pin.dropLast()))]
        } else {
            guard !confirmPin.isEmpty else { return [] }
            return [.updatePIN(String(confirmPin.dropLast()))]
        }
    }
    
    private func updatePIN(_ newPin: String) {
        if currentState == .enterPIN {
            pin = newPin
            
            if pin.count == 6 {
                switchToConfirmState()
            }
        } else {
            confirmPin = newPin
            
            if confirmPin.count == 6 {
                Task {
                    try? await perform(.verifyPIN)
                }
            }
        }
    }
    
    private func switchToConfirmState() {
        currentState = .confirmPIN
    }
    
    private func verifyPIN() async throws {
        guard pin == confirmPin else {
            throw PINError.mismatch
        }
        
        try await perform(.saveAndConfirmPIN)
    }
    
    private func saveAndConfirmPIN() async throws {
        let result = await savePINUseCase.execute(pin: pin)
        
        switch result {
        case .success:
            currentState = .success
            
            // 1.5초 후 설정 완료 콜백 호출
            try await Task.sleep(nanoseconds: 1_500_000_000)
            try await perform(.setupComplete)
        case .failure:
            throw PINError.saveFailed
        }
    }
    
    private func resetState() {
        if isError {
            isError = false
            errorMessage = ""
            
            if currentState == .confirmPIN {
                confirmPin = ""
            } else {
                pin = ""
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        isError = true
        
        if currentState == .confirmPIN {
            confirmPin = ""
        }
    }
    
    private func completeSetup() {
        onSetupComplete()
    }
}

// MARK: - 오류 정의
enum PINError: Error {
    case invalidFormat
    case mismatch
    case saveFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidFormat:
            return "PIN은 6자리 숫자여야 합니다."
        case .mismatch:
            return "입력한 PIN 번호가 일치하지 않습니다."
        case .saveFailed:
            return "PIN 저장에 실패했습니다."
        }
    }
}
