//
//  SecuritySettingsViewModel.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import Combine
import DomainModule
import SharedModule
import AuthenticationModule
import LocalAuthentication

public final class SecuritySettingsViewModel: AsyncViewModel {
    public enum Input {
        case viewDidLoad
        case toggleBiometric(Bool)
        case setupPIN
        case changePIN
        case changePassword
    }
    
    public enum Action {
        case loadSecuritySettings
        case updateBiometricSettings(Bool)
        case navigateToPINSetup
        case navigateToPINChange
        case navigateToPasswordChange
        case showError(String)
    }
    
    // MARK: - 상태
    @Published public var isPINSet: Bool = false
    @Published public var isBiometricEnabled: Bool = false
    @Published public var isBiometricAvailable: Bool = false
    @Published public var biometricType: BiometricType = .none
    @Published public var errorMessage: String = ""
    @Published public var showErrorAlert: Bool = false
    
    // MARK: - 의존성
    private let checkPINExistsUseCase: CheckPINExistsUseCaseProtocol
    private let onPINSetupTapped: (() -> Void)?
    private let onPINChangeTapped: (() -> Void)?
    private let onPasswordChangeTapped: (() -> Void)?
    
    // MARK: - 초기화
    public init(
        checkPINExistsUseCase: CheckPINExistsUseCaseProtocol,
        onPINSetupTapped: (() -> Void)? = nil,
        onPINChangeTapped: (() -> Void)? = nil,
        onPasswordChangeTapped: (() -> Void)? = nil
    ) {
        self.checkPINExistsUseCase = checkPINExistsUseCase
        self.onPINSetupTapped = onPINSetupTapped
        self.onPINChangeTapped = onPINChangeTapped
        self.onPasswordChangeTapped = onPasswordChangeTapped
    }
    
    // MARK: - AsyncViewModel 구현
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return [.loadSecuritySettings]
        case .toggleBiometric(let isEnabled):
            return [.updateBiometricSettings(isEnabled)]
        case .setupPIN:
            return [.navigateToPINSetup]
        case .changePIN:
            return [.navigateToPINChange]
        case .changePassword:
            return [.navigateToPasswordChange]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .loadSecuritySettings:
            try await loadSecuritySettings()
        case .updateBiometricSettings(let isEnabled):
            try await updateBiometricSettings(isEnabled: isEnabled)
        case .navigateToPINSetup:
            onPINSetupTapped?()
        case .navigateToPINChange:
            onPINChangeTapped?()
        case .navigateToPasswordChange:
            onPasswordChangeTapped?()
        case .showError(let message):
            await showError(message: message)
        }
    }
    
    public func handleError(_ error: Error) async {
        await showError(message: "오류가 발생했습니다: \(error.localizedDescription)")
    }
    
    // MARK: - 내부 메서드
    private func loadSecuritySettings() async throws {
        // PIN 설정 여부 확인
        isPINSet = checkPINExistsUseCase.execute()
        
        // 생체 인증 가능 여부 확인
        checkBiometricAvailability()
    }
    
    private func updateBiometricSettings(isEnabled: Bool) async throws {
        // 생체 인증 설정 업데이트 로직
        // 실제 구현에서는 UserDefaults나 Keychain 등에 저장
        isBiometricEnabled = isEnabled
    }
    
    private func checkBiometricAvailability() {
        let authContext = LAContext()
        var error: NSError?
        
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch authContext.biometryType {
            case .faceID:
                biometricType = .faceID
                isBiometricAvailable = true
            case .touchID:
                biometricType = .touchID
                isBiometricAvailable = true
            default:
                biometricType = .none
                isBiometricAvailable = false
            }
        } else {
            biometricType = .none
            isBiometricAvailable = false
        }
    }
    
    private func showError(message: String) async {
        errorMessage = message
        showErrorAlert = true
    }
} 
