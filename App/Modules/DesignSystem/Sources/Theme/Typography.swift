import SwiftUI

/// 앱 전체에서 사용되는 텍스트 스타일 정의
public struct TypographyStyle {
    // MARK: - 제목 스타일
    public let largeTitle: Font
    public let title1: Font
    public let title2: Font
    public let title3: Font
    
    // MARK: - 본문 스타일
    public let body: Font
    public let bodyBold: Font
    public let bodyMedium: Font
    public let bodySmall: Font
    
    // MARK: - 캡션 스타일
    public let caption1: Font
    public let caption2: Font
    
    // MARK: - 특수 스타일
    public let button: Font
    public let callout: Font
    public let footnote: Font
    
    // MARK: - 생성자
    init(
        largeTitle: Font,
        title1: Font,
        title2: Font,
        title3: Font,
        body: Font,
        bodyBold: Font,
        bodyMedium: Font,
        bodySmall: Font,
        caption1: Font,
        caption2: Font,
        button: Font,
        callout: Font,
        footnote: Font
    ) {
        self.largeTitle = largeTitle
        self.title1 = title1
        self.title2 = title2
        self.title3 = title3
        self.body = body
        self.bodyBold = bodyBold
        self.bodyMedium = bodyMedium
        self.bodySmall = bodySmall
        self.caption1 = caption1
        self.caption2 = caption2
        self.button = button
        self.callout = callout
        self.footnote = footnote
    }
}

// MARK: - 기본 타이포그래피 스타일
extension TypographyStyle {
    public static let `default` = TypographyStyle(
        largeTitle: .system(size: 34, weight: .bold, design: .default),
        title1: .system(size: 28, weight: .bold, design: .default),
        title2: .system(size: 22, weight: .bold, design: .default),
        title3: .system(size: 20, weight: .semibold, design: .default),
        body: .system(size: 17, weight: .regular, design: .default),
        bodyBold: .system(size: 17, weight: .bold, design: .default),
        bodyMedium: .system(size: 17, weight: .medium, design: .default),
        bodySmall: .system(size: 15, weight: .regular, design: .default),
        caption1: .system(size: 12, weight: .regular, design: .default),
        caption2: .system(size: 11, weight: .regular, design: .default),
        button: .system(size: 17, weight: .medium, design: .default),
        callout: .system(size: 16, weight: .semibold, design: .default),
        footnote: .system(size: 13, weight: .regular, design: .default)
    )
}

// MARK: - 커스텀 폰트 스타일 정의
public struct FontStyle {
    // 한글 기본 폰트 (pretendard 또는 애플의 SF Pro 대체)
    public static func pretendard(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // 폰트가 앱에 포함되어 있다면 커스텀 폰트 반환
        if let _ = UIFont(name: "Pretendard-Regular", size: size) {
            let fontName: String
            switch weight {
            case .bold: fontName = "Pretendard-Bold"
            case .semibold: fontName = "Pretendard-SemiBold" 
            case .medium: fontName = "Pretendard-Medium"
            case .light: fontName = "Pretendard-Light"
            default: fontName = "Pretendard-Regular"
            }
            return .custom(fontName, size: size)
        }
        
        // 폰트가 없으면 시스템 폰트로 대체
        return .system(size: size, weight: weight, design: .default)
    }
    
    // 숫자 폰트 (Sora 또는 애플의 SF Pro 숫자 대체)
    public static func sora(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        // 폰트가 앱에 포함되어 있다면 커스텀 폰트 반환
        if let _ = UIFont(name: "Sora-Regular", size: size) {
            let fontName: String
            switch weight {
            case .bold: fontName = "Sora-Bold"
            case .semibold: fontName = "Sora-SemiBold"
            case .medium: fontName = "Sora-Medium"
            case .light: fontName = "Sora-Light"
            default: fontName = "Sora-Regular"
            }
            return .custom(fontName, size: size)
        }
        
        // 폰트가 없으면 시스템 폰트로 대체
        return .system(size: size, weight: weight, design: .default)
    }
}

// MARK: - 환경값 키 정의
struct TypographyStyleKey: EnvironmentKey {
    static let defaultValue: TypographyStyle = .default
}

extension EnvironmentValues {
    var typographyStyle: TypographyStyle {
        get { self[TypographyStyleKey.self] }
        set { self[TypographyStyleKey.self] = newValue }
    }
}

// MARK: - 뷰 확장
extension View {
    public func typographyStyle(_ style: TypographyStyle) -> some View {
        environment(\.typographyStyle, style)
    }
} 