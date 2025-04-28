//
//  SettingsViewModel.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SharedModule

public final class SettingsViewModel: ObservableObject {
    // MARK: - 콜백
    var onLogoutButtonTapped: (() -> Void)?
    var onNotificationCenterTapped: (() -> Void)?
    var onProfileTapped: (() -> Void)?
    var onSecuritySettingsTapped: (() -> Void)?
    var onAlertSettingsTapped: (() -> Void)?
    var onCustomerServiceTapped: (() -> Void)?
    var onTermsOfServiceTapped: (() -> Void)?
    
    // MARK: - 앱 정보
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    
    // MARK: - 메서드
    func handleLogout() {
        onLogoutButtonTapped?()
    }
    
    func handleNotificationCenterTap() {
        onNotificationCenterTapped?()
    }
    
    func handleProfileTap() {
        onProfileTapped?()
    }
    
    func handleSecuritySettingsTap() {
        onSecuritySettingsTapped?()
    }
    
    func handleAlertSettingsTap() {
        onAlertSettingsTapped?()
    }
    
    func handleCustomerServiceTap() {
        onCustomerServiceTapped?()
    }
    
    func handleTermsOfServiceTap() {
        onTermsOfServiceTapped?()
    }
} 