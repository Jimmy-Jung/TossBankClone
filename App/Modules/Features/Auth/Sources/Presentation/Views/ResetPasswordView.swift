//
//  ResetPasswordView.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

struct ResetPasswordView: View {
    @ObservedObject private var viewModel: ResetPasswordViewModel
    
    init(viewModel: ResetPasswordViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            
            VStack(spacing: 16) {
                inputField(
                    title: "이메일", 
                    text: Binding(
                        get: { viewModel.email },
                        set: { viewModel.send(.updateEmail($0)) }
                    ), 
                    placeholder: "가입한 이메일을 입력해주세요", 
                    keyboardType: .emailAddress
                )
                
                infoBox
            }
            
            Spacer()
            
            sendButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .alert("오류", isPresented: $viewModel.showErrorAlert) {
            Button("확인", role: .cancel) {
                viewModel.send(.dismissError)
            }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("비밀번호 재설정")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ColorTokens.Text.primary)
            
            Text("가입한 이메일로 비밀번호 재설정 링크를\n보내드립니다.")
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
    
    private var infoBox: some View {
        Text("입력하신 이메일로 비밀번호 재설정 링크가 발송됩니다. 메일을 확인한 후 링크를 클릭하여 새 비밀번호를 설정해주세요.")
            .font(.system(size: 14))
            .foregroundColor(ColorTokens.Text.secondary)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ColorTokens.Background.secondary)
            .cornerRadius(8)
    }
    
    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorTokens.Text.primary)
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .padding(12)
                .background(ColorTokens.Background.secondary)
                .cornerRadius(8)
        }
    }
    
    private var sendButton: some View {
        TossButton(style: .primary, size: .large) {
            viewModel.send(.sendResetRequest)
        } label: {
            Text("재설정 링크 보내기")
                .font(.system(size: 16, weight: .semibold))
        }
        .disabled(viewModel.email.isEmpty || !viewModel.email.contains("@"))
        .opacity(viewModel.email.isEmpty || !viewModel.email.contains("@") ? 0.7 : 1.0)
        .padding(.bottom, 24)
    }
    
    private var backButton: some View {
        Button {
            viewModel.send(.backTapped)
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(ColorTokens.Text.primary)
        }
    }
}
