//
//  PINSetupViewModel.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import AuthenticationModule
import Combine
import SharedModule

public final class PINSetupViewModel: AsyncViewModel {
    // MARK: - Input & Action
    public enum Input {
        case viewDidLoad
        case numberTapped(Int)
        case deleteTapped
    }
    
    public enum Action {
        case updateFirstPIN(String)
        case updateConfirmPIN(String)
        case proceedToConfirmation
        case validatePINs
        case resetError
    }
    
    // MARK: - 상태 열거형
    public enum SetupState {
        case initial      // 첫 번째 PIN 입력
        case confirmation // 확인을 위한 PIN 재입력
        case success      // 설정 완료
        case error        // 오류 발생
    }
    
    // MARK: - 퍼블리셔
    @Published public var firstPIN: String = ""
    @Published public var confirmPIN: String = ""
    @Published public var currentState: SetupState = .initial
    @Published public var errorMessage: String = ""
    @Published public var isError: Bool = false
    
    // MARK: - 의존성
    private let authManager: AuthenticationManager
    
    // MARK: - 계산 속성
    public var activePIN: Binding<String> {
        Binding<String>(
            get: { self.currentState == .initial ? self.firstPIN : self.confirmPIN },
            set: { newValue in
                if self.currentState == .initial {
                    self.firstPIN = newValue
                } else {
                    self.confirmPIN = newValue
                }
            }
        )
    }
    
    public var currentPINLength: Int {
        currentState == .initial ? firstPIN.count : confirmPIN.count
    }
    
    public var headerTitle: String {
        switch currentState {
        case .initial:
            return "PIN 번호 설정"
        case .confirmation:
            return "PIN 번호 확인"
        case .success:
            return "PIN 설정 완료"
        case .error:
            return "PIN 번호 확인"
        }
    }
    
    public var headerSubtitle: String {
        switch currentState {
        case .initial:
            return "6자리 PIN 번호를 입력해주세요"
        case .confirmation:
            return "PIN 번호를 한번 더 입력해주세요"
        case .success:
            return "PIN 번호가 성공적으로 설정되었습니다"
        case .error:
            return "PIN 번호를 한번 더 입력해주세요"
        }
    }
    
    // MARK: - 생성자
    public init(authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authManager = authManager
    }

    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return []
            
        case .numberTapped(let number):
            guard currentPINLength < 6 else { return [] }
            
            var actions: [Action] = []
            
            if isError {
                actions.append(.resetError)
            }
            
            if currentState == .initial {
                let updatedPIN = firstPIN + "\(number)"
                actions.append(.updateFirstPIN(updatedPIN))
                
                if updatedPIN.count == 6 {
                    actions.append(.proceedToConfirmation)
                }
            } else {
                let updatedPIN = confirmPIN + "\(number)"
                actions.append(.updateConfirmPIN(updatedPIN))
                
                if updatedPIN.count == 6 {
                    actions.append(.validatePINs)
                }
            }
            
            return actions
            
        case .deleteTapped:
            var actions: [Action] = []
            
            if isError {
                actions.append(.resetError)
            }
            
            if currentState == .initial && !firstPIN.isEmpty {
                actions.append(.updateFirstPIN(String(firstPIN.dropLast())))
            } else if currentState == .confirmation && !confirmPIN.isEmpty {
                actions.append(.updateConfirmPIN(String(confirmPIN.dropLast())))
            }
            
            return actions
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .updateFirstPIN(let pin):
            try await updateFirstPIN(pin)
        case .updateConfirmPIN(let pin):
            try await updateConfirmPIN(pin)
        case .proceedToConfirmation:
            // 지연 시간은 async sleep으로 구현
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3초
            await proceedToConfirmation()
        case .validatePINs:
            // 지연 시간은 async sleep으로 구현
            try await Task.sleep(nanoseconds: 300_000_000) // 0.3초
            await validatePINs()
        case .resetError:
            await resetError()
        }
    }
    
    public func handleError(_ error: Error) async {
        await showError(message: "오류가 발생했습니다: \(error.localizedDescription)")
    }

// MARK: - 내부 메서드
    func updateFirstPIN(_ pin: String) async throws {
        firstPIN = pin
    }
    
    func updateConfirmPIN(_ pin: String) async throws {
        confirmPIN = pin
    }
    
    func proceedToConfirmation() async {
        withAnimation {
            currentState = .confirmation
        }
    }
    
    func validatePINs() async {
        if firstPIN == confirmPIN {
            await savePIN()
        } else {
            await showError(message: "PIN 번호가 일치하지 않습니다. 다시 시도해주세요.")
        }
    }
    
    func savePIN() async {
        // 실제로는 아래와 같이 구현 예정
        // do {
        //     let success = try await authManager.savePIN(firstPIN)
        //     if success {
        //         withAnimation {
        //             currentState = .success
        //         }
        //     } else {
        //         await showError(message: "PIN 저장에 실패했습니다. 다시 시도해주세요.")
        //     }
        // } catch {
        //     await showError(message: "PIN 저장 중 오류가 발생했습니다: \(error.localizedDescription)")
        // }
    }
    
    func showError(message: String) async {
        errorMessage = message
        withAnimation {
            isError = true
            currentState = .error
            confirmPIN = ""
        }
    }
    
    func resetError() async {
        withAnimation {
            isError = false
            errorMessage = ""
        }
    }
    
    // MARK: - 공개 인터페이스
    public func onNumberTapped(_ number: Int) {
        send(.numberTapped(number))
    }
    
    public func onDeleteTapped() {
        send(.deleteTapped)
    }
}
