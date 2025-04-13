import SwiftUI

/// 앱 전체에서 사용하는 버튼 스타일 정의
public struct TossButton<Label: View>: View {
    // MARK: - 속성
    private let style: ButtonStyle
    private let size: ButtonSize
    private let action: () -> Void
    private let label: Label
    
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.typographyStyle) private var typography
    
    // MARK: - 생성자
    public init(
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.style = style
        self.size = size
        self.action = action
        self.label = label()
    }
    
    // MARK: - 바디
    public var body: some View {
        Button(action: action) {
            label
                .font(getFont())
                .foregroundColor(getForegroundColor())
                .frame(height: getHeight())
                .frame(maxWidth: .infinity)
                .background(getBackgroundColor())
                .cornerRadius(getCornerRadius())
                .overlay(
                    RoundedRectangle(cornerRadius: getCornerRadius())
                        .stroke(getBorderColor(), lineWidth: getBorderWidth())
                )
        }
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    // MARK: - 헬퍼 메서드
    private func getFont() -> Font {
        switch size {
        case .large:
            return typography.button
        case .medium:
            return typography.bodyMedium
        case .small:
            return typography.bodySmall
        }
    }
    
    private func getHeight() -> CGFloat {
        switch size {
        case .large:
            return 56
        case .medium:
            return 48
        case .small:
            return 36
        }
    }
    
    private func getCornerRadius() -> CGFloat {
        switch size {
        case .large:
            return 16
        case .medium:
            return 12
        case .small:
            return 8
        }
    }
    
    private func getForegroundColor() -> Color {
        switch style {
        case .primary:
            return ColorTokens.Text.inverse
        case .secondary:
            return ColorTokens.Text.primary
        case .tertiary:
            return ColorTokens.Brand.primary
        case .danger:
            return ColorTokens.Text.inverse
        }
    }
    
    private func getBackgroundColor() -> Color {
        switch style {
        case .primary:
            return ColorTokens.Brand.primary
        case .secondary:
            return ColorTokens.Background.secondary
        case .tertiary:
            return .clear
        case .danger:
            return ColorTokens.State.error
        }
    }
    
    private func getBorderColor() -> Color {
        switch style {
        case .primary, .danger:
            return .clear
        case .secondary:
            return ColorTokens.Border.primary
        case .tertiary:
            return ColorTokens.Brand.primary
        }
    }
    
    private func getBorderWidth() -> CGFloat {
        switch style {
        case .primary, .danger, .secondary:
            return 0
        case .tertiary:
            return 1
        }
    }
}

// MARK: - 버튼 스타일 열거형
public enum ButtonStyle {
    case primary
    case secondary
    case tertiary
    case danger
}

// MARK: - 버튼 크기 열거형
public enum ButtonSize {
    case large
    case medium
    case small
}

// MARK: - 버튼 미리보기
struct TossButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TossButton(style: .primary, action: {}) {
                Text("프라이머리 버튼")
            }
            
            TossButton(style: .secondary, action: {}) {
                Text("세컨더리 버튼")
            }
            
            TossButton(style: .tertiary, action: {}) {
                Text("텍스트 버튼")
            }
            
            TossButton(style: .danger, action: {}) {
                Text("위험 버튼")
            }
            
            TossButton(style: .primary, size: .small, action: {}) {
                Text("작은 버튼")
            }
            
            TossButton(style: .primary, action: {}) {
                HStack {
                    Image(systemName: "plus")
                    Text("아이콘 버튼")
                }
            }
            
            TossButton(style: .primary, action: {}) {
                Text("비활성화 버튼")
            }
            .disabled(true)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 