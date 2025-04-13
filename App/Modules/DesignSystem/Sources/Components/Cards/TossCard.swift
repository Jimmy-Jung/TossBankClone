import SwiftUI

/// 앱 전체에서 사용하는 카드 컴포넌트
public struct TossCard<Content: View>: View {
    // MARK: - 속성
    private let style: CardStyle
    private let content: Content
    private let onTap: (() -> Void)?
    
    // MARK: - 생성자
    public init(
        style: CardStyle = .primary,
        onTap: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.onTap = onTap
        self.content = content()
    }
    
    // MARK: - 바디
    public var body: some View {
        contentView
            .onTapGesture {
                onTap?()
            }
    }
    
    private var contentView: some View {
        content
            .padding(style.padding)
            .background(getBackgroundColor())
            .cornerRadius(16)
            .shadow(
                color: style.hasShadow ? ColorTokens.Effect.shadow : .clear,
                radius: 8,
                x: 0,
                y: 4
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(getBorderColor(), lineWidth: style.hasBorder ? 1 : 0)
            )
    }
    
    // MARK: - 헬퍼 메서드
    private func getBackgroundColor() -> Color {
        switch style.type {
        case .primary:
            return ColorTokens.Layer.first
        case .secondary:
            return ColorTokens.Layer.second
        case .highlighted:
            return ColorTokens.Brand.primary.opacity(0.1)
        case .custom(let color):
            return color
        }
    }
    
    private func getBorderColor() -> Color {
        style.hasBorder ? ColorTokens.Border.primary : .clear
    }
}

// MARK: - 카드 스타일 구조체
public struct CardStyle {
    let type: CardType
    let padding: EdgeInsets
    let hasShadow: Bool
    let hasBorder: Bool
    
    public init(
        type: CardType = .primary,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        hasShadow: Bool = true,
        hasBorder: Bool = false
    ) {
        self.type = type
        self.padding = padding
        self.hasShadow = hasShadow
        self.hasBorder = hasBorder
    }
    
    public enum CardType {
        case primary
        case secondary
        case highlighted
        case custom(Color)
    }
    
    // 기본 스타일
    public static let primary = CardStyle()
    
    // 보조 스타일
    public static let secondary = CardStyle(
        type: .secondary,
        hasShadow: false,
        hasBorder: true
    )
    
    // 강조 스타일
    public static let highlighted = CardStyle(
        type: .highlighted,
        hasShadow: false
    )
    
    // 작은 패딩 스타일
    public static let compact = CardStyle(
        padding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
    )
}

// MARK: - 카드 미리보기
struct TossCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            TossCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("기본 카드")
                        .font(.headline)
                    Text("주요 정보를 담는 기본 카드 컴포넌트입니다.")
                        .font(.subheadline)
                }
            }
            
            TossCard(style: .secondary) {
                HStack {
                    Image(systemName: "creditcard.fill")
                        .font(.title)
                    VStack(alignment: .leading) {
                        Text("보조 카드")
                            .font(.headline)
                        Text("테두리가 있는 카드")
                            .font(.caption)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
            }
            
            TossCard(style: .highlighted) {
                Text("강조 카드")
                    .font(.headline)
            }
            
            TossCard(style: .compact, onTap: {
                print("카드 탭됨")
            }) {
                Text("작은 패딩 카드")
                    .font(.subheadline)
            }
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 