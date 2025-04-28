//
//  SettingsDIContainer.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import AuthenticationModule
import DomainModule
import SharedModule

// MARK: - 설정 모듈 DIContainer 구현
public final class SettingsDIContainer: SettingsDIContainerProtocol {
    
    private let authenticationManager: AuthenticationManagerProtocol
    private let appDIContainer: AppDIContainerProtocol
    
    public init(
        authenticationManager: AuthenticationManagerProtocol,
        appDIContainer: AppDIContainerProtocol
    ) {
        self.authenticationManager = authenticationManager
        self.appDIContainer = appDIContainer
    }
    
    // MARK: - AuthDIContainer 접근
    public func authDIContainer() -> AuthDIContainerProtocol {
        return appDIContainer.authDIContainer()
    }
    
    // MARK: - ViewModels
    public func makeSecuritySettingsViewModel(
        onPINSetupTapped: (() -> Void)?,
        onPINChangeTapped: (() -> Void)?
    ) -> any AsyncViewModel {
        return SecuritySettingsViewModel(
            checkPINExistsUseCase: makeCheckPINExistsUseCase(),
            onPINSetupTapped: onPINSetupTapped,
            onPINChangeTapped: onPINChangeTapped,
            onPasswordChangeTapped: nil
        )
    }
    
    public func makePINSetupViewModel(
        onSetupComplete: @escaping () -> Void
    ) -> any AsyncViewModel {
        return authDIContainer()
            .makePINSetupViewModel(onSetupComplete: onSetupComplete)

    }
    
    // MARK: - UseCases
    public func makeCheckPINExistsUseCase() -> CheckPINExistsUseCaseProtocol {
        return CheckPINExistsUseCase(authenticationManager: authenticationManager)
    }
}
