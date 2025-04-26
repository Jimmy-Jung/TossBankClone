import Foundation
import LocalAuthentication
import Security

/// 인증 관리자 프로토콜
public protocol AuthenticationManagerProtocol: AnyObject {
    /// 현재 인증 상태 확인
    var isAuthenticated: Bool { get }
    
    /// 로그인 메서드
    func login(email: String, password: String) async throws -> Bool
    
    /// 로그아웃 메서드
    func logout() async throws
    
    /// 인증 토큰 가져오기
    func getAuthToken() -> String?
    
    /// 회원가입 메서드
    func register(email: String, password: String, name: String) async throws -> Bool
}

/// 인증 관리자 구현
public final class AuthenticationManager: AuthenticationManagerProtocol {
    // MARK: - 싱글톤 인스턴스
    public static let shared = AuthenticationManager()
    
    private let keychainService = "io.tuist.TossBankClone"
    private let pinKey = "user_pin"
    private let authContext = LAContext()
    
    // MARK: - 속성
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "app.auth.token"
    private let userIdKey = "app.auth.userId"
    
    // MARK: - 초기화
    public init() {}
    
    // MARK: - AuthenticationManagerProtocol 구현
    
    public var isAuthenticated: Bool {
        return getAuthToken() != nil
    }
    
    public func login(email: String, password: String) async throws -> Bool {
        // 실제 구현에서는 API를 호출하여 인증을 수행해야 함
        // 여기서는 테스트를 위해 간단한 구현만 제공
        
        // 테스트 사용자 확인 (실제 구현에서는 서버 응답 사용)
        if email == "test@test.com" && password == "test" {
            // 인증 성공 시 토큰 저장
            let mockToken = "mock_token_\(UUID().uuidString)"
            let mockUserId = "user_\(Int.random(in: 1000...9999))"
            
            userDefaults.set(mockToken, forKey: tokenKey)
            userDefaults.set(mockUserId, forKey: userIdKey)
            
            return true
        } else {
            // 인증 실패
            throw AuthenticationError.invalidCredentials
        }
    }
    
    public func logout() async throws {
        // 실제 구현에서는 서버에 로그아웃 요청을 보낼 수 있음
        
        // 로컬 토큰 제거
        userDefaults.removeObject(forKey: tokenKey)
        userDefaults.removeObject(forKey: userIdKey)
    }
    
    public func getAuthToken() -> String? {
        return userDefaults.string(forKey: tokenKey)
    }
    
    public func register(email: String, password: String, name: String) async throws -> Bool {
        // 실제 구현에서는 API를 호출하여 회원가입을 수행해야 함
        // 여기서는 테스트를 위해 간단한 구현만 제공
        
        // 기본 유효성 검사
        guard email.contains("@"), password.count >= 8, !name.isEmpty else {
            throw AuthenticationError.invalidInput
        }
        
        // 테스트용 회원가입 성공 응답
        let mockToken = "mock_token_\(UUID().uuidString)"
        let mockUserId = "user_\(Int.random(in: 1000...9999))"
        
        userDefaults.set(mockToken, forKey: tokenKey)
        userDefaults.set(mockUserId, forKey: userIdKey)
        
        return true
    }
    
    // MARK: - 생체 인증
    public func authenticateBiometric() async -> Result<Bool, AuthError> {
        // 생체 인증 가능성 체크
        var error: NSError?
        guard authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                return .failure(.biometricError(error))
            }
            return .failure(.biometricUnavailable)
        }
        
        // 생체 인증 프롬프트
        do {
            let success = try await authContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "계정에 접근하기 위해 생체인증이 필요합니다"
            )
            return .success(success)
        } catch {
            return .failure(.biometricError(error as NSError))
        }
    }
    
    // MARK: - PIN 관리
    public func savePIN(_ pin: String) -> Result<Void, AuthError> {
        guard pin.count == 6, pin.allSatisfy({ $0.isNumber }) else {
            return .failure(.invalidPin)
        }
        
        // 키체인에 PIN 저장
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecValueData as String: pin.data(using: .utf8)!,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            return .success(())
        } else {
            return .failure(.keychainError(status))
        }
    }
    
    public func validatePIN(_ pin: String) -> Result<Bool, AuthError> {
        guard pin.count == 6, pin.allSatisfy({ $0.isNumber }) else {
            return .failure(.invalidPin)
        }
        
        // 키체인에서 PIN 조회
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess, let retrievedData = dataTypeRef as? Data, let storedPin = String(data: retrievedData, encoding: .utf8) {
            return .success(pin == storedPin)
        } else if status == errSecItemNotFound {
            return .failure(.pinNotSet)
        } else {
            return .failure(.keychainError(status))
        }
    }
    
    public func isPINSet() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: pinKey,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func changePIN(oldPin: String, newPin: String) -> Result<Void, AuthError> {
        // 먼저 기존 PIN 검증
        let validateResult = validatePIN(oldPin)
        switch validateResult {
        case .success(let isValid):
            if isValid {
                // 검증 성공 시 새 PIN 저장
                return savePIN(newPin)
            } else {
                return .failure(.invalidPin)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - 로그인 시도 관리
    private var loginAttempts = 0
    private let maxLoginAttempts = 3
    
    public func recordFailedLoginAttempt() -> Int {
        loginAttempts += 1
        return maxLoginAttempts - loginAttempts
    }
    
    public func resetLoginAttempts() {
        loginAttempts = 0
    }
    
    public func isAccountLocked() -> Bool {
        return loginAttempts >= maxLoginAttempts
    }
}

// MARK: - 인증 관련 오류 정의
public enum AuthError: Error {
    case biometricUnavailable
    case biometricError(NSError)
    case invalidPin
    case pinNotSet
    case keychainError(OSStatus)
    case accountLocked
    case unauthorized
    case unknown
}

/// 인증 오류 정의
public enum AuthenticationError: Error {
    case invalidCredentials
    case invalidInput
    case networkError
    case serverError
    case unknown
} 
