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
        /// 반전된 텍스트 색상
        public static let inverse = Color("TextInverse", bundle: .module)
    }
    
    /// 배경 색상
    public enum Background {
        /// 기본 배경 색상
        public static let primary = Color("BackgroundPrimary", bundle: .module)
        /// 보조 배경 색상
        public static let secondary = Color("BackgroundSecondary", bundle: .module)
        /// 3차 배경 색상
        public static let tertiary = Color("BackgroundTertiary", bundle: .module)
        /// 반전된 배경 색상
        public static let inverse = Color("BackgroundInverse", bundle: .module)
        /// 카드 배경 색상
        public static let card = Color("BackgroundCard", bundle: .module)
    }
    
    /// 경계선 색상
    public enum Border {
        /// 기본 경계선 색상
        public static let primary = Color("BorderPrimary", bundle: .module)
        /// 구분선 색상
        public static let divider = Color("BorderDivider", bundle: .module)
    }
    
    /// 상태 색상
    public enum State {
        /// 성공 상태 색상
        public static let success = Color("StateSuccess", bundle: .module)
        /// 경고 상태 색상
        public static let warning = Color("StateWarning", bundle: .module)
        /// 오류 상태 색상
        public static let error = Color("StateError", bundle: .module)
        /// 정보 상태 색상
        public static let info = Color("StateInfo", bundle: .module)
    }
    
    /// 계층 색상
    public enum Layer {
        /// 1차 계층 색상
        public static let first = Color("LayerOne", bundle: .module)
        /// 2차 계층 색상
        public static let second = Color("LayerTwo", bundle: .module)
        /// 3차 계층 색상
        public static let third = Color("LayerThree", bundle: .module)
    }
    
    /// 효과 색상
    public enum Effect {
        /// 그림자 색상
        public static let shadow = Color("EffectShadow", bundle: .module)
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
    
    /// Text.disabled 색상을 UIColor로 반환
    static var textDisabled: UIColor {
        UIColor(named: "TextDisabled", in: .module, compatibleWith: nil)!
    }
    
    /// Text.inverse 색상을 UIColor로 반환
    static var textInverse: UIColor {
        UIColor(named: "TextInverse", in: .module, compatibleWith: nil)!
    }
    
    /// Background.primary 색상을 UIColor로 반환
    static var backgroundPrimary: UIColor {
        UIColor(named: "BackgroundPrimary", in: .module, compatibleWith: nil)!
    }
    
    /// Background.secondary 색상을 UIColor로 반환
    static var backgroundSecondary: UIColor {
        UIColor(named: "BackgroundSecondary", in: .module, compatibleWith: nil)!
    }
    
    /// Background.tertiary 색상을 UIColor로 반환
    static var backgroundTertiary: UIColor {
        UIColor(named: "BackgroundTertiary", in: .module, compatibleWith: nil)!
    }
    
    /// Background.inverse 색상을 UIColor로 반환
    static var backgroundInverse: UIColor {
        UIColor(named: "BackgroundInverse", in: .module, compatibleWith: nil)!
    }
    
    /// Background.card 색상을 UIColor로 반환
    static var backgroundCard: UIColor {
        UIColor(named: "BackgroundCard", in: .module, compatibleWith: nil)!
    }
    
    /// Border.primary 색상을 UIColor로 반환
    static var borderPrimary: UIColor {
        UIColor(named: "BorderPrimary", in: .module, compatibleWith: nil)!
    }
    
    /// Border.divider 색상을 UIColor로 반환
    static var borderDivider: UIColor {
        UIColor(named: "BorderDivider", in: .module, compatibleWith: nil)!
    }
    
    /// State.success 색상을 UIColor로 반환
    static var stateSuccess: UIColor {
        UIColor(named: "StateSuccess", in: .module, compatibleWith: nil)!
    }
    
    /// State.warning 색상을 UIColor로 반환
    static var stateWarning: UIColor {
        UIColor(named: "StateWarning", in: .module, compatibleWith: nil)!
    }
    
    /// State.error 색상을 UIColor로 반환
    static var stateError: UIColor {
        UIColor(named: "StateError", in: .module, compatibleWith: nil)!
    }
    
    /// State.info 색상을 UIColor로 반환
    static var stateInfo: UIColor {
        UIColor(named: "StateInfo", in: .module, compatibleWith: nil)!
    }
    
    /// Layer.first 색상을 UIColor로 반환
    static var layerFirst: UIColor {
        UIColor(named: "LayerOne", in: .module, compatibleWith: nil)!
    }
    
    /// Layer.second 색상을 UIColor로 반환
    static var layerSecond: UIColor {
        UIColor(named: "LayerTwo", in: .module, compatibleWith: nil)!
    }
    
    /// Layer.third 색상을 UIColor로 반환
    static var layerThird: UIColor {
        UIColor(named: "LayerThree", in: .module, compatibleWith: nil)!
    }
    
    /// Effect.shadow 색상을 UIColor로 반환
    static var effectShadow: UIColor {
        UIColor(named: "EffectShadow", in: .module, compatibleWith: nil)!
    }
} 