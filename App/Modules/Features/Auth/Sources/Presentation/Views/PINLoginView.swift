import SwiftUI
import DesignSystem
import TossBankKit

public struct PINLoginView: View {
    @StateObject private var viewModel = PINLoginViewModel()
    private let onLoginSuccess: () -> Void
    
    public init(onLoginSuccess: @escaping () -> Void) {
        self.onLoginSuccess = onLoginSuccess
    }
    
    public var body: some View {
        VStack(spacing: 40) {
            headerView
            
            Spacer()
            
            if viewModel.currentState == .success {
                successView
            } else {
                PINIndicator(
                    pinLength: viewModel.pin.count,
                    isError: viewModel.isError,
                    maxLength: 6
                )
                .padding(.bottom, 40)
                
                if viewModel.currentState == .locked {
                    lockedView
                } else {
                    PINKeypad(
                        onNumberTapped: viewModel.onNumberTapped,
                        onDeleteTapped: viewModel.onDeleteTapped
                    )
                    
                    if viewModel.isBiometricAvailable {
                        biometricButton
                            .padding(.top, 32)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: viewModel.currentState) { newState in
            if newState == .success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onLoginSuccess()
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.headerTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ColorTokens.Text.primary)
            
            Text(viewModel.headerSubtitle)
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
            
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var biometricButton: some View {
        Button {
            viewModel.authenticateWithBiometrics()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.biometricType.systemImageName)
                    .font(.system(size: 18))
                Text("\(viewModel.biometricType.displayName)로 로그인")
                    .font(.system(size: 16))
            }
            .foregroundColor(.accentColor)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            
            Text("로그인 성공")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 8)
            
            Text("잠시 후 메인 화면으로 이동합니다")
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var lockedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "lock.fill")
                .resizable()
                .frame(width: 60, height: 80)
                .foregroundColor(.red)
                .padding(.bottom, 16)
            
            Text("계정이 잠겼습니다")
                .font(.system(size: 20, weight: .semibold))
            
            Text("너무 많은 로그인 시도로 계정이 잠겼습니다.\n고객센터에 문의해 주세요.")
                .font(.system(size: 14))
                .foregroundColor(ColorTokens.Text.secondary)
                .multilineTextAlignment(.center)
            
            TossButton(style: .primary, size: .large) {
                // 고객센터 연결 로직
            } label: {
                Text("고객센터 연결하기")
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 프리뷰
struct PINLoginView_Previews: PreviewProvider {
    static var previews: some View {
        PINLoginView {
            print("로그인 성공")
        }
    }
} 
