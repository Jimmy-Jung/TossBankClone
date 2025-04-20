import SwiftUI

// MARK: - PIN 표시기
public struct PINIndicator: View {
    // MARK: - 속성
    private let pinLength: Int
    private let isError: Bool
    private let maxLength: Int
    
    // MARK: - 생성자
    public init(pinLength: Int, isError: Bool = false, maxLength: Int = 6) {
        self.pinLength = pinLength
        self.isError = isError
        self.maxLength = maxLength
    }
    
    // MARK: - 바디
    public var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<maxLength, id: \.self) { index in
                Circle()
                    .fill(index < pinLength
                          ? (isError ? ColorTokens.State.error : ColorTokens.Brand.primary)
                          : ColorTokens.Background.secondary)
                    .frame(width: 16, height: 16)
                    .animation(.spring(response: 0.2), value: pinLength)
                    .animation(.spring(response: 0.2), value: isError)
            }
        }
    }
}
