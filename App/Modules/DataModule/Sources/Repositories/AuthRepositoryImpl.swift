//
//  AuthRepositoryImpl.swift
//  DataModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import DomainModule
import NetworkModule

/// 인증 리포지토리 구현
public class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    // MARK: - 속성
    private let apiClient: APIClient
    private var cachedUserProfile: UserEntity?
    
    // MARK: - 생성자
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - 로그인 관련 메서드
    
    /// 로그인 실행
    public func login(email: String, password: String) async throws -> AuthResultEntity {
        do {
            let request = LoginRequest(email: email, password: password)
            let authResultDTO = try await apiClient.send(request)
            return authResultDTO.toEntity()
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 회원가입 실행
    public func register(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String?
    ) async throws -> AuthResultEntity {
        do {
            let request = RegisterRequest(
                email: email,
                password: password,
                fullName: fullName,
                phoneNumber: phoneNumber
            )
            let authResultDTO = try await apiClient.send(request)
            return authResultDTO.toEntity()
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 비밀번호 재설정 요청
    public func resetPassword(email: String) async throws -> Bool {
        do {
            let request = PasswordResetRequest(email: email)
            _ = try await apiClient.send(request)
            return true
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 비밀번호 변경
    public func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws -> Bool {
        do {
            let request = ChangePasswordRequest(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            _ = try await apiClient.send(request)
            return true
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 액세스 토큰 갱신
    public func refreshToken(refreshToken: String) async throws -> AuthTokenEntity {
        do {
            let request = RefreshTokenRequest(refreshToken: refreshToken)
            let tokenDTO = try await apiClient.send(request)
            return tokenDTO.toEntity()
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 사용자 정보 조회
    public func fetchUserProfile() async throws -> UserEntity {
        // 캐시된 프로필이 있으면 반환
        if let cachedUserProfile = cachedUserProfile {
            return cachedUserProfile
        }
        
        do {
            let request = UserProfileRequest()
            let userDTO = try await apiClient.send(request)
            let userEntity = userDTO.toEntity()
            
            // 프로필 캐싱
            cachedUserProfile = userEntity
            
            return userEntity
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 사용자 정보 업데이트
    public func updateUserProfile(
        fullName: String?,
        phoneNumber: String?
    ) async throws -> UserEntity {
        do {
            let request = UpdateProfileRequest(
                fullName: fullName,
                phoneNumber: phoneNumber
            )
            let userDTO = try await apiClient.send(request)
            let userEntity = userDTO.toEntity()
            
            // 프로필 캐시 업데이트
            cachedUserProfile = userEntity
            
            return userEntity
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    /// 로그아웃
    public func logout() async throws {
        do {
            let request = LogoutRequest()
            _ = try await apiClient.send(request)
            
            // 로그아웃 시 캐시 초기화
            cachedUserProfile = nil
        } catch let error as NetworkError {
            throw mapToAuthError(error)
        } catch {
            throw AuthError.unknown
        }
    }
    
    // MARK: - 유틸리티 메서드
    
    /// 네트워크 오류를 Auth 오류로 매핑
    private func mapToAuthError(_ error: NetworkError) -> AuthError {
        switch error {
        case .unauthorized:
            return .invalidCredentials
        case .httpError(let statusCode, _):
            switch statusCode {
            case 401:
                return .invalidCredentials
            case 403:
                return .accountLocked
            case 404:
                return .userNotFound
            case 409:
                return .duplicateEmail
            case 422:
                return .weakPassword
            case 429:
                return .rateLimitExceeded
            default:
                return .serverError
            }
        case .serverError:
            return .serverError
        case .noInternetConnection, .offline:
            return .networkError
        default:
            return .unknown
        }
    }
} 