import SwiftUI
import Combine
import TossBankKit
import LocalAuthentication

public final class PINLoginViewModel: ObservableObject {
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
    private var cancellables = Set<AnyCancellable>()
    
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
        checkBiometricAvailability()
    }
    
    // MARK: - 공개 메서드
    public func onNumberTapped(_ number: Int) {
        guard pin.count < 6 && currentState != .locked else { return }
        
        if isError {
            resetError()
        }
        
        pin.append("\(number)")
        
        if pin.count == 6 {
            authenticateWithPIN()
        }
    }
    
    public func onDeleteTapped() {
        guard !pin.isEmpty && currentState != .locked else { return }
        
        if isError {
            resetError()
        }
        
        pin.removeLast()
    }
    
    public func authenticateWithBiometrics() {
        guard isBiometricAvailable else { return }
        
        currentState = .authenticating
        
        // authManager.authenticateBiometric()
        //     .receive(on: DispatchQueue.main)
        //     .sink { [weak self] completion in
        //         if case .failure(let error) = completion {
        //             self?.showError(message: "생체 인증에 실패했습니다: \(error.localizedDescription)")
        //         }
        //     } receiveValue: { [weak self] success in
        //         if success {
        //             self?.handleAuthenticationSuccess()
        //         } else {
        //             self?.showError(message: "생체 인증에 실패했습니다. PIN을 입력해주세요.")
        //         }
        //     }
        //     .store(in: &cancellables)
    }
    
    // MARK: - 비공개 메서드
    private func authenticateWithPIN() {
        currentState = .authenticating
        
        // 인증 지연 시뮬레이션
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
        //     guard let self = self else { return }
        //     
        //     self.authManager.validatePIN(self.pin)
        //         .receive(on: DispatchQueue.main)
        //         .sink { completion in
        //             if case .failure(let error) = completion {
        //                 self.showError(message: "인증 중 오류가 발생했습니다: \(error.localizedDescription)")
        //             }
        //         } receiveValue: { success in
        //             if success {
        //                 self.handleAuthenticationSuccess()
        //             } else {
        //                 self.remainingAttempts -= 1
        //                 
        //                 if self.remainingAttempts <= 0 {
        //                     self.handleAccountLocked()
        //                 } else {
        //                     self.showError(message: "잘못된 PIN 번호입니다.")
        //                 }
        //             }
        //         }
        //         .store(in: &self.cancellables)
        // }
    }
    
    private func handleAuthenticationSuccess() {
        withAnimation {
            currentState = .success
        }
    }
    
    private func handleAccountLocked() {
        withAnimation {
            currentState = .locked
            errorMessage = "계정이 잠겼습니다. 관리자에게 문의하세요."
            isError = true
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        pin = ""
        
        withAnimation {
            currentState = .error
            isError = true
        }
    }
    
    private func resetError() {
        withAnimation {
            isError = false
            errorMessage = ""
            currentState = .initial
        }
    }
    
    private func checkBiometricAvailability() {
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
