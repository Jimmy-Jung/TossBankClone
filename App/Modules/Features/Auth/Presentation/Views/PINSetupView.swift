import SwiftUI
import TossBankKit
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
                    maxDigits: 6,
                    isError: viewModel.isError
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
                .foregroundColor(.label)
            
            Text(viewModel.headerSubtitle)
                .font(.system(size: 16))
                .foregroundColor(.secondaryLabel)
            
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
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
            
            TossButton(
                title: "완료",
                style: .filled,
                size: .large,
                action: onCompleted
            )
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