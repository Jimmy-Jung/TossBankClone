//
//  PINUseCases.swift
//  DomainModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import AuthenticationModule

// MARK: - PIN 관련 UseCase 프로토콜

public protocol ValidatePINUseCaseProtocol {
    func execute(pin: String) async -> Result<Bool, EntityError>
}

public protocol SavePINUseCaseProtocol {
    func execute(pin: String) async -> Result<Void, EntityError>
}

public protocol ChangePINUseCaseProtocol {
    func execute(oldPin: String, newPin: String) async -> Result<Void, EntityError>
}

public protocol BiometricAuthUseCaseProtocol {
    func execute() async -> Result<Bool, EntityError>
}

public protocol CheckPINExistsUseCaseProtocol {
    func execute() -> Bool
}

// MARK: - UseCase 구현

public final class ValidatePINUseCase: ValidatePINUseCaseProtocol {
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
    
    public func execute(pin: String) async -> Result<Bool, EntityError> {
        let result = authenticationManager.validatePIN(pin)
        
        switch result {
        case .success(let isValid):
            return .success(isValid)
        case .failure(let error):
            switch error {
            case .invalidPin:
                return .failure(.validationError)
            case .pinNotSet:
                return .failure(.notFound)
            case .keychainError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        }
    }
}

public final class SavePINUseCase: SavePINUseCaseProtocol {
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
    
    public func execute(pin: String) async -> Result<Void, EntityError> {
        let result = authenticationManager.savePIN(pin)
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            switch error {
            case .invalidPin:
                return .failure(.validationError)
            case .keychainError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        }
    }
}

public final class ChangePINUseCase: ChangePINUseCaseProtocol {
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
    
    public func execute(oldPin: String, newPin: String) async -> Result<Void, EntityError> {
        let result = authenticationManager.changePIN(oldPin: oldPin, newPin: newPin)
        
        switch result {
        case .success:
            return .success(())
        case .failure(let error):
            switch error {
            case .invalidPin:
                return .failure(.invalidInput)
            case .keychainError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        }
    }
}

public final class BiometricAuthUseCase: BiometricAuthUseCaseProtocol {
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
    
    public func execute() async -> Result<Bool, EntityError> {
        let result = await authenticationManager.authenticateBiometric()
        
        switch result {
        case .success(let success):
            return .success(success)
        case .failure(let error):
            switch error {
            case .biometricUnavailable:
                return .failure(.accessDenied)
            case .biometricError:
                return .failure(.validationError)
            default:
                return .failure(.unexpectedError(error))
            }
        }
    }
}

public final class CheckPINExistsUseCase: CheckPINExistsUseCaseProtocol {
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(authenticationManager: AuthenticationManagerProtocol) {
        self.authenticationManager = authenticationManager
    }
    
    public func execute() -> Bool {
        return authenticationManager.isPINSet()
    }
} 