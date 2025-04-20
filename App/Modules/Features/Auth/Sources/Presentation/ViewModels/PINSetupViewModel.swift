import SwiftUI
import Combine
import TossBankKit

public final class PINSetupViewModel: ObservableObject {
    // MARK: - 상태 열거형
    public enum SetupState {
        case initial      // 첫 번째 PIN 입력
        case confirmation // 확인을 위한 PIN 재입력
        case success      // 설정 완료
        case error        // 오류 발생
    }
    
    // MARK: - 퍼블리셔
    @Published public var firstPIN: String = ""
    @Published public var confirmPIN: String = ""
    @Published public var currentState: SetupState = .initial
    @Published public var errorMessage: String = ""
    @Published public var isError: Bool = false
    
    // MARK: - 의존성
    private let authManager: AuthenticationManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 계산 속성
    public var activePIN: Binding<String> {
        Binding<String>(
            get: { self.currentState == .initial ? self.firstPIN : self.confirmPIN },
            set: { newValue in
                if self.currentState == .initial {
                    self.firstPIN = newValue
                } else {
                    self.confirmPIN = newValue
                }
            }
        )
    }
    
    public var currentPINLength: Int {
        currentState == .initial ? firstPIN.count : confirmPIN.count
    }
    
    public var headerTitle: String {
        switch currentState {
        case .initial:
            return "PIN 번호 설정"
        case .confirmation:
            return "PIN 번호 확인"
        case .success:
            return "PIN 설정 완료"
        case .error:
            return "PIN 번호 확인"
        }
    }
    
    public var headerSubtitle: String {
        switch currentState {
        case .initial:
            return "6자리 PIN 번호를 입력해주세요"
        case .confirmation:
            return "PIN 번호를 한번 더 입력해주세요"
        case .success:
            return "PIN 번호가 성공적으로 설정되었습니다"
        case .error:
            return "PIN 번호를 한번 더 입력해주세요"
        }
    }
    
    // MARK: - 생성자
    public init(authManager: AuthenticationManager = AuthenticationManager.shared) {
        self.authManager = authManager
    }
    
    // MARK: - 공개 메서드
    public func onNumberTapped(_ number: Int) {
        guard currentPINLength < 6 else { return }
        
        if isError {
            resetError()
        }
        
        if currentState == .initial {
            firstPIN.append("\(number)")
            if firstPIN.count == 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.proceedToConfirmation()
                }
            }
        } else {
            confirmPIN.append("\(number)")
            if confirmPIN.count == 6 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.validatePINs()
                }
            }
        }
    }
    
    public func onDeleteTapped() {
        if isError {
            resetError()
        }
        
        if currentState == .initial && !firstPIN.isEmpty {
            firstPIN.removeLast()
        } else if currentState == .confirmation && !confirmPIN.isEmpty {
            confirmPIN.removeLast()
        }
    }
    
    // MARK: - 비공개 메서드
    private func proceedToConfirmation() {
        withAnimation {
            currentState = .confirmation
        }
    }
    
    private func validatePINs() {
        if firstPIN == confirmPIN {
            savePIN()
        } else {
            showError(message: "PIN 번호가 일치하지 않습니다. 다시 시도해주세요.")
        }
    }
    
    private func savePIN() {
        // authManager.savePIN(firstPIN)
        //     .receive(on: DispatchQueue.main)
        //     .sink { completion in
        //         if case .failure(let error) = completion {
        //             self.showError(message: "PIN 저장 중 오류가 발생했습니다: \(error.localizedDescription)")
        //         }
        //     } receiveValue: { success in
        //         if success {
        //             withAnimation {
        //                 self.currentState = .success
        //             }
        //         } else {
        //             self.showError(message: "PIN 저장에 실패했습니다. 다시 시도해주세요.")
        //         }
        //     }
        //     .store(in: &cancellables)
    }
    
    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            isError = true
            currentState = .error
            confirmPIN = ""
        }
    }
    
    private func resetError() {
        withAnimation {
            isError = false
            errorMessage = ""
        }
    }
} 
