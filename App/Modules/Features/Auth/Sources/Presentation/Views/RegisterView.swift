//
//  RegisterView.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

struct RegisterView: View {
    @ObservedObject private var viewModel: RegisterViewModel
    
    init(viewModel: RegisterViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            headerView
            
            VStack(spacing: 16) {
                inputField(
                    title: "이름", 
                    text: Binding(
                        get: { viewModel.name },
                        set: { viewModel.send(.updateName($0)) }
                    ), 
                    placeholder: "실명을 입력해주세요"
                )
                
                inputField(
                    title: "이메일", 
                    text: Binding(
                        get: { viewModel.email },
                        set: { viewModel.send(.updateEmail($0)) }
                    ), 
                    placeholder: "예) example@email.com", 
                    keyboardType: .emailAddress
                )
                
                inputField(
                    title: "비밀번호", 
                    text: Binding(
                        get: { viewModel.password },
                        set: { viewModel.send(.updatePassword($0)) }
                    ), 
                    placeholder: "8자 이상 입력해주세요", 
                    isSecure: true
                )
                
                inputField(
                    title: "비밀번호 확인", 
                    text: Binding(
                        get: { viewModel.confirmPassword },
                        set: { viewModel.send(.updateConfirmPassword($0)) }
                    ), 
                    placeholder: "비밀번호를 한번 더 입력해주세요", 
                    isSecure: true
                )
                
                inputField(
                    title: "전화번호 (선택)", 
                    text: Binding(
                        get: { viewModel.phoneNumber },
                        set: { viewModel.send(.updatePhoneNumber($0)) }
                    ), 
                    placeholder: "'-' 없이 입력해주세요", 
                    keyboardType: .phonePad
                )
            }
            
            Spacer()
            
            registerButton
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
            Text("회원가입")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ColorTokens.Text.primary)
            
            Text("토스뱅크 서비스 이용을 위해\n계정을 만들어주세요.")
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 16)
    }
    
    private func inputField(title: String, text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ColorTokens.Text.primary)
            
            if isSecure {
                SecureField(placeholder, text: text)
                    .padding(12)
                    .background(ColorTokens.Background.secondary)
                    .cornerRadius(8)
            } else {
                TextField(placeholder, text: text)
                    .keyboardType(keyboardType)
                    .padding(12)
                    .background(ColorTokens.Background.secondary)
                    .cornerRadius(8)
            }
        }
    }
    
    private var registerButton: some View {
        TossButton(style: .primary, size: .large) {
            viewModel.send(.register)
        } label: {
            Text("회원가입")
                .font(.system(size: 16, weight: .semibold))
        }
        .disabled(!isFormValid)
        .opacity(isFormValid ? 1.0 : 0.7)
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
    
    private var isFormValid: Bool {
        return !viewModel.name.isEmpty &&
               !viewModel.email.isEmpty && viewModel.email.contains("@") &&
               viewModel.password.count >= 8 &&
               viewModel.password == viewModel.confirmPassword
    }
}
