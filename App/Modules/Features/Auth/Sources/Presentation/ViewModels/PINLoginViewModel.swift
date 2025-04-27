import SwiftUI
import AuthenticationModule
import Combine
import LocalAuthentication
import SharedModule

public final class PINLoginViewModel: AsyncViewModel {
    // MARK: - Input & Action
    public enum Input {
        case viewDidLoad
        case numberTapped(Int)
        case deleteTapped
        case useBiometrics
    }
    
    public enum Action {
        case updatePIN(String)
        case authenticateWithPIN
        case authenticateWithBiometrics
        case resetError
        case lockAccount
        case showError(String)
        case checkBiometricAvailability
    }
    
    // MARK: - 상태 열거형
    public enum LoginState {
        case initial
        case authenticating
        case success
        case error
        case locked
    }
    
    // MARK: - 퍼블리셔
    @Published public var pin: String = ""
    @Published public var currentState: LoginState = .initial
    @Published public var errorMessage: String = ""
    @Published public var isError: Bool = false
    @Published public var remainingAttempts: Int = 5
    @Published public var isBiometricAvailable: Bool = false
    @Published public var biometricType: BiometricType = .none
    
    // MARK: - 의존성
    private let authManager: AuthenticationManager
    
    // MARK: - 계산 속성
    public var headerTitle: String {
        switch currentState {
        case .initial:
            return "PIN 번호 입력"
        case .authenticating:
            return "인증 중..."
        case .success:
            return "인증 성공"
        case .error:
            return "인증 실패"
        case .locked:
            return "계정 잠김"
        }
    }
    
    public var headerSubtitle: String {
        switch currentState {
        case .initial:
            return "설정한 6자리 PIN 번호를 입력해주세요"
        case .authenticating:
            return "PIN 번호를 확인하고 있습니다"
        case .success:
            return "성공적으로 인증되었습니다"
        case .error:
            return "남은 시도 횟수: \(remainingAttempts)회"
        case .locked:
            return "너무 많은 시도로 계정이 잠겼습니다"
        }
    }
    
    // MARK: - 생성자
    public init(authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return [.checkBiometricAvailability]
            
        case .numberTapped(let number):
            guard pin.count < 6 && currentState != .locked else { return [] }
            
            var actions: [Action] = []
            
            if isError {
                actions.append(.resetError)
            }
            
            let updatedPIN = pin + "\(number)"
            actions.append(.updatePIN(updatedPIN))
            
            if updatedPIN.count == 6 {
                actions.append(.authenticateWithPIN)
            }
            
            return actions
            
        case .deleteTapped:
            guard !pin.isEmpty && currentState != .locked else { return [] }
            
            var actions: [Action] = []
            
            if isError {
                actions.append(.resetError)
            }
            
            let updatedPIN = String(pin.dropLast())
            actions.append(.updatePIN(updatedPIN))
            
            return actions
            
        case .useBiometrics:
            guard isBiometricAvailable else { return [] }
            return [.authenticateWithBiometrics]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .updatePIN(let updatedPIN):
            try await updatePIN(updatedPIN)
        case .authenticateWithPIN:
            try await authenticateWithPIN()
        case .authenticateWithBiometrics:
            try await authenticateWithBiometrics()
        case .resetError:
            await resetError()
        case .lockAccount:
            await lockAccount()
        case .showError(let message):
            await showError(message: message)
        case .checkBiometricAvailability:
            await checkBiometricAvailability()
        }
    }
    
    public func handleError(_ error: Error) async {
        await showError(message: "오류가 발생했습니다: \(error.localizedDescription)")
    }
    
    // MARK: - 내부 메서드
    
    func updatePIN(_ updatedPIN: String) async throws {
        pin = updatedPIN
    }
    
    func authenticateWithPIN() async throws {
        currentState = .authenticating
        
        // 인증 지연 시뮬레이션
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 대기
        
        // 실제로는 아래와 같이 구현 예정
        // do {
        //     let isValid = try await authManager.validatePIN(pin)
        //     if isValid {
        //         await handleAuthenticationSuccess()
        //     } else {
        //         remainingAttempts -= 1
        //
        //         if remainingAttempts <= 0 {
        //             await lockAccount()
        //         } else {
        //             await showError(message: "잘못된 PIN 번호입니다.")
        //         }
        //     }
        // } catch {
        //     await showError(message: "인증 중 오류가 발생했습니다: \(error.localizedDescription)")
        // }
    }
    
    func authenticateWithBiometrics() async throws {
        currentState = .authenticating
        
        // 실제로는 아래와 같이 구현 예정
        // do {
        //     let isValid = try await authManager.authenticateBiometric()
        //     if isValid {
        //         await handleAuthenticationSuccess()
        //     } else {
        //         await showError(message: "생체 인증에 실패했습니다. PIN을 입력해주세요.")
        //     }
        // } catch {
        //     await showError(message: "생체 인증에 실패했습니다: \(error.localizedDescription)")
        // }
    }
    
    func handleAuthenticationSuccess() async {
        withAnimation {
            currentState = .success
        }
    }
    
    func lockAccount() async {
        withAnimation {
            currentState = .locked
            errorMessage = "계정이 잠겼습니다. 관리자에게 문의하세요."
            isError = true
        }
    }
    
    func showError(message: String) async {
        errorMessage = message
        pin = ""
        
        withAnimation {
            currentState = .error
            isError = true
        }
    }
    
    func resetError() async {
        withAnimation {
            isError = false
            errorMessage = ""
            currentState = .initial
        }
    }
    
    func checkBiometricAvailability() async {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .faceID:
                biometricType = .faceID
                isBiometricAvailable = true
            case .touchID:
                biometricType = .touchID
                isBiometricAvailable = true
            default:
                biometricType = .none
                isBiometricAvailable = false
            }
        } else {
            biometricType = .none
            isBiometricAvailable = false
        }
    }
    
    // MARK: - 공개 인터페이스
    public func onNumberTapped(_ number: Int) {
        send(.numberTapped(number))
    }
    
    public func onDeleteTapped() {
        send(.deleteTapped)
    }
    
    public func authenticateWithBiometrics() {
        send(.useBiometrics)
    }
}

public enum BiometricType {
    case none
    case touchID
    case faceID
    
    var systemImageName: String {
        switch self {
        case .none:
            return ""
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        }
    }
    
    var displayName: String {
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
