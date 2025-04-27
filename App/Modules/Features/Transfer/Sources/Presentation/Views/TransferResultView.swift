//
//  TransferResultView.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DesignSystem

struct TransferResultView: View {
    @ObservedObject var viewModel: TransferResultViewModel
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 성공/실패 아이콘
            Image(systemName: viewModel.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(viewModel.success ? ColorTokens.State.success : ColorTokens.State.error)
                .padding(.bottom, 16)
            
            // 메시지
            Text(viewModel.success ? "송금이 완료되었습니다" : "송금에 실패했습니다")
                .font(typography.title2)
                .foregroundColor(ColorTokens.Text.primary)
            
            if viewModel.success {
                Text("거래번호: \(viewModel.transactionId)")
                    .font(typography.footnote)
                    .foregroundColor(ColorTokens.Text.secondary)
            }
            
            Spacer()
            
            // 완료 버튼
            TossButton(
                style: .primary,
                size: .large,
                action: {
                    viewModel.send(.doneButtonTapped)
                }
            ) {
                Text("확인")
            }
        }
        .padding(16)
        .background(ColorTokens.Background.primary)
        .onAppear {
            viewModel.send(.viewDidLoad)
        }
    }
} 
