//
//  AuthEntities.swift
//  DomainModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation

// MARK: - 인증 관련 엔티티

/// 사용자 엔티티
public struct UserEntity {
    public let id: String
    public let email: String
    public let fullName: String
    public let phoneNumber: String?
    public let isVerified: Bool
    public let createdAt: Date
    
    public init(
        id: String,
        email: String,
        fullName: String,
        phoneNumber: String? = nil,
        isVerified: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.phoneNumber = phoneNumber
        self.isVerified = isVerified
        self.createdAt = createdAt
    }
}

/// 인증 토큰 엔티티
public struct AuthTokenEntity {
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
}

/// 인증 결과 엔티티
public struct AuthResultEntity {
    public let token: AuthTokenEntity
    public let isNewUser: Bool
    
    public init(
        token: AuthTokenEntity,
        isNewUser: Bool = false
    ) {
        self.token = token
        self.isNewUser = isNewUser
    }
}

// MARK: - 엔티티 오류 정의

/// 엔티티 오류 타입
public enum EntityError: Error {
    case invalidData
    case notFound
    case accessDenied
    case serverError
    case networkError
    case repositoryError(Error)
    case validationError
    case limitExceeded
    case invalidInput
    case insufficientFunds
    case duplicateItem
    case unexpectedError(Error)
} 

public enum BiometricType {
    case none
    case touchID
    case faceID
    
    public var systemImageName: String {
        switch self {
        case .none:
            return ""
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        }
    }
    
    public var displayName: String {
        switch self {
        case .none:
            return ""
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        }
    }
}
