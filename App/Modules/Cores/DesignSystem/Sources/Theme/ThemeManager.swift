import SwiftUI

/// 앱 테마 관리 클래스
public final class ThemeManager: ObservableObject {
    // MARK: - 싱글톤 인스턴스
    public static let shared = ThemeManager()
    
    // MARK: - 발행된 속성
    @Published public private(set) var currentTheme: AppTheme
    
    private init() {
        // 시스템 설정 감지
        let isDark = UITraitCollection.current.userInterfaceStyle == .dark
        self.currentTheme = .system // 기본값은 시스템 설정 따름
        
        // 설정에서 사용자 테마 로드
        if let savedTheme = UserDefaults.standard.string(forKey: "app_theme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.currentTheme = theme
        }
    }
    
    // MARK: - 테마 변경 메서드
    public func setTheme(_ theme: AppTheme) {
        self.currentTheme = theme
        
        // 설정 저장
        UserDefaults.standard.set(theme.rawValue, forKey: "app_theme")
        
        // 색상 및 UI 업데이트 알림
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
    
    // MARK: - 시스템 테마 변경 감지
    public func updateForTraitCollectionChange(_ traitCollection: UITraitCollection) {
        guard currentTheme == .system else { return }
        
        // 시스템 테마가 변경되었을 때만 알림
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

/// 앱 테마 유형
public enum AppTheme: String {
    case light
    case dark
    case system
}

// MARK: - 노티피케이션 확장
extension Notification.Name {
    static let themeDidChange = Notification.Name("app.theme.didChange")
}

// MARK: - 환경 키 정의
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
} 