//
//  AuthUseCases.swift
//  DomainModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import AuthenticationModule

// MARK: - UseCase 프로토콜

public protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async -> Result<AuthResultEntity, EntityError>
}

public protocol RegisterUseCaseProtocol {
    func execute(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String?
    ) async -> Result<AuthResultEntity, EntityError>
}

public protocol ResetPasswordUseCaseProtocol {
    func execute(email: String) async -> Result<Bool, EntityError>
}

public protocol ChangePasswordUseCaseProtocol {
    func execute(currentPassword: String, newPassword: String) async -> Result<Bool, EntityError>
}

public protocol RefreshTokenUseCaseProtocol {
    func execute(refreshToken: String) async -> Result<AuthTokenEntity, EntityError>
}

public protocol FetchUserProfileUseCaseProtocol {
    func execute() async -> Result<UserEntity, EntityError>
}

public protocol UpdateUserProfileUseCaseProtocol {
    func execute(fullName: String?, phoneNumber: String?) async -> Result<UserEntity, EntityError>
}

public protocol LogoutUseCaseProtocol {
    func execute() async -> Result<Void, EntityError>
}

// MARK: - UseCase 구현

public final class LoginUseCase: LoginUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let authenticationManager: AuthenticationManagerProtocol
    
    public init(
        authRepository: AuthRepositoryProtocol,
        authenticationManager: AuthenticationManagerProtocol
    ) {
        self.authRepository = authRepository
        self.authenticationManager = authenticationManager
    }
    
    public func execute(email: String, password: String) async -> Result<AuthResultEntity, EntityError> {
        do {
            // 먼저 AuthenticationManager로 로그인 시도
            let authSuccess = try await authenticationManager.login(email: email, password: password)
            
            if authSuccess {
                // 인증 관리자 로그인 성공 시 Repository 통해 토큰 및 사용자 정보 가져오기
                let result = try await authRepository.login(email: email, password: password)
                return .success(result)
            } else {
                return .failure(.invalidInput)
            }
        } catch let error as AuthenticationError {
            // 인증 관리자 에러 처리
            switch error {
            case .invalidCredentials:
                return .failure(.invalidInput)
            case .invalidInput:
                return .failure(.validationError)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch let error as AuthError {
            // AuthError 처리
            switch error {
            case .invalidCredentials:
                return .failure(.invalidInput)
            case .accountLocked, .accountNotVerified:
                return .failure(.accessDenied)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class RegisterUseCase: RegisterUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String?
    ) async -> Result<AuthResultEntity, EntityError> {
        do {
            let result = try await authRepository.register(
                email: email,
                password: password,
                fullName: fullName,
                phoneNumber: phoneNumber
            )
            return .success(result)
        } catch let error as AuthError {
            switch error {
            case .duplicateEmail:
                return .failure(.duplicateItem)
            case .weakPassword:
                return .failure(.validationError)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(email: String) async -> Result<Bool, EntityError> {
        do {
            let result = try await authRepository.resetPassword(email: email)
            return .success(result)
        } catch let error as AuthError {
            switch error {
            case .userNotFound:
                return .failure(.notFound)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class ChangePasswordUseCase: ChangePasswordUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(currentPassword: String, newPassword: String) async -> Result<Bool, EntityError> {
        do {
            let result = try await authRepository.changePassword(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            return .success(result)
        } catch let error as AuthError {
            switch error {
            case .invalidCredentials:
                return .failure(.invalidInput)
            case .weakPassword:
                return .failure(.validationError)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class RefreshTokenUseCase: RefreshTokenUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(refreshToken: String) async -> Result<AuthTokenEntity, EntityError> {
        do {
            let token = try await authRepository.refreshToken(refreshToken: refreshToken)
            return .success(token)
        } catch let error as AuthError {
            switch error {
            case .invalidToken, .sessionExpired:
                return .failure(.accessDenied)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class FetchUserProfileUseCase: FetchUserProfileUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute() async -> Result<UserEntity, EntityError> {
        do {
            let user = try await authRepository.fetchUserProfile()
            return .success(user)
        } catch let error as AuthError {
            switch error {
            case .userNotFound:
                return .failure(.notFound)
            case .sessionExpired, .invalidToken:
                return .failure(.accessDenied)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class UpdateUserProfileUseCase: UpdateUserProfileUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute(fullName: String?, phoneNumber: String?) async -> Result<UserEntity, EntityError> {
        do {
            let user = try await authRepository.updateUserProfile(
                fullName: fullName,
                phoneNumber: phoneNumber
            )
            return .success(user)
        } catch let error as AuthError {
            switch error {
            case .userNotFound:
                return .failure(.notFound)
            case .sessionExpired, .invalidToken:
                return .failure(.accessDenied)
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class LogoutUseCase: LogoutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    
    public init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    public func execute() async -> Result<Void, EntityError> {
        do {
            try await authRepository.logout()
            return .success(())
        } catch let error as AuthError {
            switch error {
            case .sessionExpired, .invalidToken:
                // 로그아웃은 이미 로그아웃 상태여도 성공으로 간주
                return .success(())
            case .networkError:
                return .failure(.networkError)
            case .serverError:
                return .failure(.serverError)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
} 
