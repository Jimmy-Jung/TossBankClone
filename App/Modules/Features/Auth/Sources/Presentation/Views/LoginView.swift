//
//  LoginView.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import SharedModule

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    
    init(viewModel: LoginViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 로고
            Image(systemName: "building.columns.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.blue)
                .padding(.bottom, 16)
            
            Text("토스뱅크")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 40)
            
            // 입력 필드
            VStack(spacing: 16) {
                TextField("이메일", text: Binding(
                    get: { viewModel.email },
                    set: { viewModel.send(.updateEmail($0)) }
                ))
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("비밀번호", text: Binding(
                    get: { viewModel.password },
                    set: { viewModel.send(.updatePassword($0)) }
                ))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
            
            // 로그인 버튼
            Button(action: {
                viewModel.send(.login)
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("로그인")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(viewModel.isLoading || !viewModel.isInputValid)
            .opacity(viewModel.isInputValid ? 1.0 : 0.7)
            
            // 회원가입 링크
            Button(action: {
                viewModel.send(.showRegister)
            }) {
                Text("아직 계정이 없으신가요? 회원가입")
                    .foregroundColor(.blue)
            }
            .padding(.top, 16)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("로그인 실패"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("확인")) {
                    viewModel.send(.dismissError)
                }
            )
        }
    }
}


