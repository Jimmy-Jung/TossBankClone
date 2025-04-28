//
//  AuthAPIRequests.swift
//  DataModule
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import NetworkModule

// MARK: - 인증 관련 API 요청

/// 로그인 요청
public struct LoginRequest: APIRequest {
    public typealias Response = AuthResultDTO
    
    public var path: String {
        return "/api/auth/login"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var parameters: [String: Any]? {
        return [
            "email": email,
            "password": password
        ]
    }
    
    private let email: String
    private let password: String
    
    public init(email: String, password: String) {
        self.email = email
        self.password = password
    }
}

/// 회원가입 요청
public struct RegisterRequest: APIRequest {
    public typealias Response = AuthResultDTO
    
    public var path: String {
        return "/api/auth/register"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var parameters: [String: Any]? {
        var params: [String: Any] = [
            "email": email,
            "password": password,
            "fullName": fullName
        ]
        
        if let phoneNumber = phoneNumber {
            params["phoneNumber"] = phoneNumber
        }
        
        return params
    }
    
    private let email: String
    private let password: String
    private let fullName: String
    private let phoneNumber: String?
    
    public init(
        email: String,
        password: String,
        fullName: String,
        phoneNumber: String?
    ) {
        self.email = email
        self.password = password
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
}

/// 비밀번호 재설정 요청
public struct PasswordResetRequest: APIRequest {
    public typealias Response = EmptyResponse
    
    public var path: String {
        return "/api/auth/password/reset"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var parameters: [String: Any]? {
        return ["email": email]
    }
    
    private let email: String
    
    public init(email: String) {
        self.email = email
    }
}

/// 비밀번호 변경 요청
public struct ChangePasswordRequest: APIRequest {
    public typealias Response = EmptyResponse
    
    public var path: String {
        return "/api/auth/password/change"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var parameters: [String: Any]? {
        return [
            "currentPassword": currentPassword,
            "newPassword": newPassword
        ]
    }
    
    private let currentPassword: String
    private let newPassword: String
    
    public init(currentPassword: String, newPassword: String) {
        self.currentPassword = currentPassword
        self.newPassword = newPassword
    }
}

/// 토큰 갱신 요청
public struct RefreshTokenRequest: APIRequest {
    public typealias Response = AuthTokenDTO
    
    public var path: String {
        return "/api/auth/token/refresh"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public var parameters: [String: Any]? {
        return ["refreshToken": refreshToken]
    }
    
    private let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

/// 사용자 프로필 요청
public struct UserProfileRequest: APIRequest {
    public typealias Response = UserDTO
    
    public var path: String {
        return "/api/auth/user/profile"
    }
    
    public var method: HTTPMethod {
        return .get
    }
    
    public init() {}
}

/// 사용자 프로필 업데이트 요청
public struct UpdateProfileRequest: APIRequest {
    public typealias Response = UserDTO
    
    public var path: String {
        return "/api/auth/user/profile"
    }
    
    public var method: HTTPMethod {
        return .put
    }
    
    public var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        
        if let fullName = fullName {
            params["fullName"] = fullName
        }
        
        if let phoneNumber = phoneNumber {
            params["phoneNumber"] = phoneNumber
        }
        
        return params
    }
    
    private let fullName: String?
    private let phoneNumber: String?
    
    public init(fullName: String?, phoneNumber: String?) {
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
}

/// 로그아웃 요청
public struct LogoutRequest: APIRequest {
    public typealias Response = EmptyResponse
    
    public var path: String {
        return "/api/auth/logout"
    }
    
    public var method: HTTPMethod {
        return .post
    }
    
    public init() {}
} 