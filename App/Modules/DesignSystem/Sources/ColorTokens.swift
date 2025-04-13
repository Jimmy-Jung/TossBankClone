import SwiftUI

/// 앱 전체에서 사용되는 색상 토큰 정의
public enum ColorTokens {
    /// 주요 브랜드 색상
    public enum Brand {
        /// 메인 블루 색상
        public static let primary = Color("BrandPrimary", bundle: .module)
        /// 보조 색상
        public static let secondary = Color("BrandSecondary", bundle: .module)
        /// 강조 색상
        public static let accent = Color("BrandAccent", bundle: .module)
    }
    
    /// 텍스트 색상
    public enum Text {
        /// 기본 텍스트 색상
        public static let primary = Color("TextPrimary", bundle: .module)
        /// 보조 텍스트 색상
        public static let secondary = Color("TextSecondary", bundle: .module)
        /// 비활성화된 텍스트 색상
        public static let disabled = Color("TextDisabled", bundle: .module)
        /// 링크 텍스트 색상
        public static let link = Color("TextLink", bundle: .module)
    }
    
    /// 배경 색상
    public enum Background {
        /// 기본 배경 색상
        public static let primary = Color("BackgroundPrimary", bundle: .module)
        /// 보조 배경 색상
        public static let secondary = Color("BackgroundSecondary", bundle: .module)
        /// 카드 배경 색상
        public static let card = Color("BackgroundCard", bundle: .module)
    }
}

/// UIKit에서 사용할 수 있는 확장
public extension UIColor {
    /// Brand.primary 색상을 UIColor로 반환
    static var brandPrimary: UIColor {
        UIColor(named: "BrandPrimary", in: .module, compatibleWith: nil)!
    }
    
    /// Brand.secondary 색상을 UIColor로 반환
    static var brandSecondary: UIColor {
        UIColor(named: "BrandSecondary", in: .module, compatibleWith: nil)!
    }
    
    /// Brand.accent 색상을 UIColor로 반환
    static var brandAccent: UIColor {
        UIColor(named: "BrandAccent", in: .module, compatibleWith: nil)!
    }
    
    /// Text.primary 색상을 UIColor로 반환
    static var textPrimary: UIColor {
        UIColor(named: "TextPrimary", in: .module, compatibleWith: nil)!
    }
    
    /// Text.secondary 색상을 UIColor로 반환
    static var textSecondary: UIColor {
        UIColor(named: "TextSecondary", in: .module, compatibleWith: nil)!
    }
    
    /// Background.primary 색상을 UIColor로 반환
    static var backgroundPrimary: UIColor {
        UIColor(named: "BackgroundPrimary", in: .module, compatibleWith: nil)!
    }
    
    /// Background.secondary 색상을 UIColor로 반환
    static var backgroundSecondary: UIColor {
        UIColor(named: "BackgroundSecondary", in: .module, compatibleWith: nil)!
    }
} 