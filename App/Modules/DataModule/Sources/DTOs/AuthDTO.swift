//
//  AuthDTO.swift
//  DataModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import DomainModule

// MARK: - 인증 관련 DTO

/// 사용자 DTO
public struct UserDTO: Codable {
    public let id: String
    public let email: String
    public let fullName: String
    public let phoneNumber: String?
    public let isVerified: Bool
    public let createdAt: TimeInterval
    
    public init(
        id: String,
        email: String,
        fullName: String,
        phoneNumber: String? = nil,
        isVerified: Bool = false,
        createdAt: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.isVerified = isVerified
        self.createdAt = createdAt
    }
    
    // 도메인 엔티티로 변환
    public func toEntity() -> UserEntity {
        return UserEntity(
            id: id,
            email: email,
            fullName: fullName,
            phoneNumber: phoneNumber,
            isVerified: isVerified,
            createdAt: Date(timeIntervalSince1970: createdAt)
        )
    }
}

/// 인증 토큰 DTO
public struct AuthTokenDTO: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let userId: String
    
    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: Int,
        userId: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.userId = userId
    }
    
    // 도메인 엔티티로 변환
    public func toEntity() -> AuthTokenEntity {
        return AuthTokenEntity(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            userId: userId
        )
    }
}

/// 인증 결과 DTO
public struct AuthResultDTO: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresIn: Int
    public let userId: String
    public let isNewUser: Bool
    
    public init(
        accessToken: String,
        refreshToken: String,
        expiresIn: Int,
        userId: String,
        isNewUser: Bool = false
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
        self.userId = userId
        self.isNewUser = isNewUser
    }
    
    // 도메인 엔티티로 변환
    public func toEntity() -> AuthResultEntity {
        let token = AuthTokenEntity(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresIn: expiresIn,
            userId: userId
        )
        
        return AuthResultEntity(
            token: token,
            isNewUser: isNewUser
        )
    }
} 