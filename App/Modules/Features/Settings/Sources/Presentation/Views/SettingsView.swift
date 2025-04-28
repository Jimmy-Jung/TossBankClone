//
//  SettingsView.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    public init(viewModel: SettingsViewModel?) {
        guard let viewModel = viewModel else {
            fatalError("PINLoginView requires a valid PINLoginViewModel")
        }
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        List {
            Section(header: Text("계정")) {
                Button(action: {
                    viewModel.handleProfileTap()
                }) {
                    SettingsRow(title: "내 프로필", icon: "person.fill")
                }
                
                Button(action: {
                    viewModel.handleSecuritySettingsTap()
                }) {
                    SettingsRow(title: "보안 설정", icon: "lock.fill")
                }
            }
            
            Section(header: Text("알림")) {
                Button(action: {
                    viewModel.handleNotificationCenterTap()
                }) {
                    SettingsRow(title: "알림 센터", icon: "bell.fill")
                }
                
                Button(action: {
                    viewModel.handleAlertSettingsTap()
                }) {
                    SettingsRow(title: "알림 설정", icon: "bell.badge.fill")
                }
            }
            
            Section(header: Text("앱 정보")) {
                Button(action: {}) {
                    SettingsRow(title: "앱 버전", icon: "info.circle.fill", value: viewModel.appVersion)
                }
                
                Button(action: {
                    viewModel.handleCustomerServiceTap()
                }) {
                    SettingsRow(title: "고객센터", icon: "questionmark.circle.fill")
                }
                
                Button(action: {
                    viewModel.handleTermsOfServiceTap()
                }) {
                    SettingsRow(title: "이용약관", icon: "doc.text.fill")
                }
            }
            
            Section {
                Button(action: {
                    viewModel.handleLogout()
                }) {
                    Text("로그아웃")
                        .foregroundColor(ColorTokens.State.error)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

public struct SettingsRow: View {
    let title: String
    let icon: String
    var value: String? = nil
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(ColorTokens.Brand.primary)
                .frame(width: 30, height: 30)
            
            Text(title)
                .foregroundColor(ColorTokens.Text.primary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(ColorTokens.Text.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(ColorTokens.Text.secondary)
            }
        }
        .padding(.vertical, 4)
    }
} 
