import SwiftUI
import DesignSystem

/// PIN 설정 화면
public struct PINSetupView: View {
    @StateObject private var viewModel = PINSetupViewModel()
    private let onCompleted: () -> Void
    
    public init(onCompleted: @escaping () -> Void) {
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        VStack(spacing: 40) {
            headerView
            
            Spacer()
            
            if viewModel.currentState == .success {
                successView
            } else {
                PINIndicator(
                    pinLength: viewModel.currentPINLength,
                    isError: viewModel.isError,
                    maxLength: 6
                )
                .padding(.bottom, 40)
                
                PINKeypad(
                    onNumberTapped: viewModel.onNumberTapped,
                    onDeleteTapped: viewModel.onDeleteTapped
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.headerTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ColorTokens.Text.primary)
            
            Text(viewModel.headerSubtitle)
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
            
            Text(viewModel.errorMessage)
                .font(.system(size: 14))
                .foregroundColor(.red)
                .padding(.top, 8)
                .opacity(viewModel.isError ? 1 : 0) // Alpha 값 조절
                .animation(.easeInOut, value: viewModel.isError) // 애니메이션 추가
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            
            Text("PIN 번호가 성공적으로 설정되었습니다")
                .font(.system(size: 18, weight: .medium))
                .multilineTextAlignment(.center)
            
            TossButton(style: .primary, size: .large) {
                onCompleted()
            } label: {
                Text("완료")
            }
            .padding(.top, 20)
        }
        .padding(.horizontal, 24)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                onCompleted()
            }
        }
    }
}

// MARK: - 프리뷰
struct PINSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PINSetupView {
            print("PIN 설정 완료")
        }
    }
} 
