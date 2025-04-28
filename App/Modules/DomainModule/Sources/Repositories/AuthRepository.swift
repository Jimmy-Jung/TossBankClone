//
//  AuthRepository.swift
//  DomainModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation

// MARK: - AuthRepository 프로토콜
public protocol AuthRepositoryProtocol {
    /// 로그인 실행
    func login(email: String, password: String) async throws -> AuthResultEntity
    
    /// 회원가입 실행
    func register(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String?
    ) async throws -> AuthResultEntity
    
    /// 비밀번호 재설정 요청
    func resetPassword(email: String) async throws -> Bool
    
    /// 비밀번호 변경
    func changePassword(
        currentPassword: String,
        newPassword: String
    ) async throws -> Bool
    
    /// 액세스 토큰 갱신
    func refreshToken(refreshToken: String) async throws -> AuthTokenEntity
    
    /// 사용자 정보 조회
    func fetchUserProfile() async throws -> UserEntity
    
    /// 사용자 정보 업데이트
    func updateUserProfile(
        fullName: String?,
        phoneNumber: String?
    ) async throws -> UserEntity
    
    /// 로그아웃
    func logout() async throws
}

// MARK: - 인증 관련 오류
public enum AuthError: Error {
    case invalidCredentials
    case accountLocked
    case accountNotVerified
    case sessionExpired
    case invalidToken
    case userNotFound
    case duplicateEmail
    case weakPassword
    case networkError
    case serverError
    case rateLimitExceeded
    case unknown
} 