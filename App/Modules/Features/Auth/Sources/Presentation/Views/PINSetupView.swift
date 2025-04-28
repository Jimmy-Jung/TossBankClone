//
//  PINSetupView.swift
//  AuthFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

/// PIN 설정 화면
public struct PINSetupView: View {
    @ObservedObject private var viewModel: PINSetupViewModel
    
    public init(viewModel: PINSetupViewModel?) {
        guard let viewModel = viewModel else {
            fatalError("PINSetupView requires a valid PINSetupViewModel")
        }
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 40) {
            headerView
            
            Spacer()
            
            if viewModel.currentState == .success {
                successView
            } else {
                PINIndicator(
                    pinLength: viewModel.currentState == .enterPIN ? viewModel.pin.count : viewModel.confirmPin.count,
                    isError: viewModel.isError,
                    maxLength: 6
                )
                .padding(.bottom, 40)
                
                PINKeypad(
                    onNumberTapped: { number in
                        viewModel.send(.numberTapped(number))
                    },
                    onDeleteTapped: {
                        viewModel.send(.deleteTapped)
                    }
                )
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.send(.viewDidLoad)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.headerTitle)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(ColorTokens.Text.primary)
            
            Text(viewModel.headerSubtitle)
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
            
            if viewModel.isError {
                Text(viewModel.errorMessage)
                    .font(.system(size: 14))
                    .foregroundColor(ColorTokens.State.error)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var successView: some View {
        VStack(spacing: 32) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(ColorTokens.Brand.primary)
            
            Text("PIN 설정 완료")
                .font(.system(size: 24, weight: .bold))
                .padding(.bottom, 8)
            
            Text("PIN 번호가 성공적으로 설정되었습니다")
                .font(.system(size: 16))
                .foregroundColor(ColorTokens.Text.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - 프리뷰
struct PINSetupView_Previews: PreviewProvider {
    static var previews: some View {
        PINSetupView(viewModel: nil)
    }
} 
