//
//  SecuritySettingsView.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

public struct SecuritySettingsView: View {
    @ObservedObject private var viewModel: SecuritySettingsViewModel
    
    public init(viewModel: SecuritySettingsViewModel?) {
        guard let viewModel = viewModel else {
            fatalError("PINLoginView requires a valid PINLoginViewModel")
        }
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        List {
            Section(header: Text("PIN 설정")) {
                if viewModel.isPINSet {
                    Button(action: {
                        viewModel.send(.changePIN)
                    }) {
                        SettingsRow(title: "PIN 번호 변경", icon: "lock.rotation")
                    }
                } else {
                    Button(action: {
                        viewModel.send(.setupPIN)
                    }) {
                        SettingsRow(title: "PIN 번호 설정", icon: "lock.shield")
                    }
                }
            }
            
            if viewModel.isBiometricAvailable {
                Section(header: Text("생체 인증")) {
                    Toggle(isOn: Binding(
                        get: { viewModel.isBiometricEnabled },
                        set: { viewModel.send(.toggleBiometric($0)) }
                    )) {
                        HStack {
                            Image(systemName: viewModel.biometricType.systemImageName)
                                .foregroundColor(ColorTokens.Brand.primary)
                                .frame(width: 30, height: 30)
                            
                            Text("\(viewModel.biometricType.displayName) 사용")
                                .foregroundColor(ColorTokens.Text.primary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: ColorTokens.Brand.primary))
                }
            }
            
            Section(header: Text("계정 보안")) {
                Button(action: {
                    viewModel.send(.changePassword)
                }) {
                    SettingsRow(title: "비밀번호 변경", icon: "key.fill")
                }
            }
            
            Section(header: Text("정보")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("PIN 번호는 앱 로그인 및 중요 거래 시 사용됩니다.")
                        .font(.footnote)
                        .foregroundColor(ColorTokens.Text.secondary)
                    
                    if viewModel.isBiometricAvailable {
                        Text("생체 인증을 사용하면 PIN 입력 없이 빠르게 로그인할 수 있습니다.")
                            .font(.footnote)
                            .foregroundColor(ColorTokens.Text.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("보안 설정")
        .listStyle(InsetGroupedListStyle())
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("오류"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .onAppear {
            viewModel.send(.viewDidLoad)
        }
    }
} 
