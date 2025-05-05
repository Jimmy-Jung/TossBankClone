//
//  AuthDIContainer.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import NetworkModule
import AuthenticationModule
import SharedModule
import DataModule
import DomainModule

public final class AuthDIContainer: AuthDIContainerProtocol {
    // MARK: - 속성
    private let environment: AppEnvironment
    private(set) public var authenticationManager: AuthenticationManagerProtocol
    private let networkService: NetworkServiceProtocol
    
    // MARK: - 초기화
    public init(
        environment: AppEnvironment,
        authenticationManager: AuthenticationManagerProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.environment = environment
        self.authenticationManager = authenticationManager
        self.networkService = networkService
        
        if environment == .test {
            setupMockData()
        }
    }

    // MARK: - 내부 의존성 생성 메서드
    private func createAPIClient() -> APIClient {
        return NetworkAPIClient(networkService: networkService)
    }
    
    private func createAuthRepository() -> AuthRepositoryProtocol {
        return AuthRepositoryImpl(apiClient: createAPIClient())
    }
    
    // MARK: - UseCase 생성 메서드
    private func createLoginUseCase() -> LoginUseCaseProtocol {
        return LoginUseCase(
            authRepository: createAuthRepository(),
            authenticationManager: authenticationManager
        )
    }
    
    private func createRegisterUseCase() -> RegisterUseCaseProtocol {
        return RegisterUseCase(authRepository: createAuthRepository())
    }
    
    private func createResetPasswordUseCase() -> ResetPasswordUseCaseProtocol {
        return ResetPasswordUseCase(authRepository: createAuthRepository())
    }
    
    private func createFetchUserProfileUseCase() -> FetchUserProfileUseCaseProtocol {
        return FetchUserProfileUseCase(authRepository: createAuthRepository())
    }
    
    // PIN 관련 UseCase 생성 메서드
    private func createValidatePINUseCase() -> ValidatePINUseCaseProtocol {
        return ValidatePINUseCase(authenticationManager: authenticationManager)
    }
    
    private func createSavePINUseCase() -> SavePINUseCaseProtocol {
        return SavePINUseCase(authenticationManager: authenticationManager)
    }
    
    private func createChangePINUseCase() -> ChangePINUseCaseProtocol {
        return ChangePINUseCase(authenticationManager: authenticationManager)
    }
    
    private func createBiometricAuthUseCase() -> BiometricAuthUseCaseProtocol {
        return BiometricAuthUseCase(authenticationManager: authenticationManager)
    }
    
    private func createCheckPINExistsUseCase() -> CheckPINExistsUseCaseProtocol {
        return CheckPINExistsUseCase(authenticationManager: authenticationManager)
    }
    
    // MARK: - ViewModel 생성 메서드
    public func makeLoginViewModel(
        onLoginSuccess: @escaping () -> Void,
        onRegisterTapped: @escaping () -> Void
    ) -> any AsyncViewModel {
        return LoginViewModel(
            loginUseCase: createLoginUseCase(),
            onLoginSuccess: onLoginSuccess,
            onRegisterTapped: onRegisterTapped
        )
    }
    
    public func makePINLoginViewModel(
        onLoginSuccess: @escaping () -> Void
    ) -> any AsyncViewModel {
        return PINLoginViewModel(
            validatePINUseCase: createValidatePINUseCase(),
            biometricAuthUseCase: createBiometricAuthUseCase(),
            onLoginSuccess: onLoginSuccess
        )
    }
    
    public func makePINSetupViewModel(
        onSetupComplete: @escaping () -> Void
    ) -> any AsyncViewModel {
        return PINSetupViewModel(
            savePINUseCase: createSavePINUseCase(),
            onSetupComplete: onSetupComplete
        )
    }
    
    public func makeRegisterViewModel(
        onRegisterSuccess: @escaping () -> Void,
        onBackTapped: @escaping () -> Void
    ) -> any AsyncViewModel {
        return RegisterViewModel(
            registerUseCase: createRegisterUseCase(),
            onRegisterSuccess: onRegisterSuccess,
            onBackTapped: onBackTapped
        )
    }
    
    public func makeResetPasswordViewModel(
        onResetSent: @escaping () -> Void,
        onBackTapped: @escaping () -> Void
    ) -> any AsyncViewModel {
        return ResetPasswordViewModel(
            resetPasswordUseCase: createResetPasswordUseCase(),
            onResetSent: onResetSent,
            onBackTapped: onBackTapped
        )
    }
    
    public func makeCheckPINExistsUseCase() -> CheckPINExistsUseCaseProtocol {
        return createCheckPINExistsUseCase()
    }
    
    // MARK: - 테스트 데이터 설정 메서드
    private func setupDefaultTestData() {
        // 기본 성공 응답 설정 예시
        let mockNetworkService = networkService as? MockNetworkService
        mockNetworkService?.setDefaultHandler { _ in
            return (Data(), HTTPURLResponse(), nil)
        }
    }
    
    // 자세한 목 데이터 설정
    private func setupMockData() {
        guard let mockNetworkService = networkService as? MockNetworkService else { return }
        
        // 테스트 환경에서는 PIN이 설정되지 않았다고 가정
        // PIN이 이미 설정되어 있다면 삭제
        let pinQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "io.tuist.TossBankClone",
            kSecAttrAccount as String: "user_pin"
        ]
        SecItemDelete(pinQuery as CFDictionary)
            
        print("🧪 테스트 환경: PIN 설정 삭제")
        
        // 로그인 토큰도 삭제하여 새로 로그인하도록 설정
        UserDefaults.standard.removeObject(forKey: "app.auth.token")
        UserDefaults.standard.removeObject(forKey: "app.auth.userId")
        
        print("🧪 테스트 환경: 로그인 토큰 삭제")
        
        // 인증 관련 목 데이터
        let loginResponseDTO: [String: Any] = [
            "accessToken": "sample-access-token",
            "refreshToken": "sample-refresh-token",
            "expiresIn": 3600,
            "userId": "user-123",
            "isNewUser": false
        ]
        
        let userProfileDTO: [String: Any] = [
            "id": "user-123",
            "email": "test@example.com",
            "fullName": "홍길동",
            "phoneNumber": "010-1234-5678",
            "isVerified": true,
            "createdAt": Date().timeIntervalSince1970
        ]
        
        do {
            // 로그인 API 응답 설정
            let loginJsonData = try JSONSerialization.data(withJSONObject: loginResponseDTO, options: [])
            mockNetworkService.setRequestHandler(for: "/api/auth/login") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/auth/login")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (loginJsonData, response, nil)
            }
            
            // 회원가입 API 응답 설정
            mockNetworkService.setRequestHandler(for: "/api/auth/register") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/auth/register")!,
                    statusCode: 201,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (loginJsonData, response, nil)
            }
            
            // 사용자 프로필 API 응답 설정
            let userProfileJsonData = try JSONSerialization.data(withJSONObject: userProfileDTO, options: [])
            mockNetworkService.setRequestHandler(for: "/api/auth/user/profile") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/auth/user/profile")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (userProfileJsonData, response, nil)
            }
            
            // 비밀번호 재설정 API 응답 설정
            mockNetworkService.setRequestHandler(for: "/api/auth/password/reset") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/auth/password/reset")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (Data(), response, nil)
            }
            
            print("인증 관련 목 데이터 설정 완료")
        } catch {
            print("목 데이터 설정 오류: \(error.localizedDescription)")
        }
    }
}
