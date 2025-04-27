//
//  TransferConfirmView.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct TransferConfirmView: View {
    @ObservedObject var viewModel: TransferConfirmViewModel
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        VStack(spacing: 24) {
            // 송금 정보 카드
            VStack(spacing: 16) {
                // 송금액
                VStack(spacing: 4) {
                    Text("송금액")
                        .font(typography.footnote)
                        .foregroundColor(ColorTokens.Text.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text(formatCurrency(viewModel.amount))
                        .font(typography.title1)
                        .foregroundColor(ColorTokens.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                    .background(ColorTokens.Border.divider)
                
                // 출금 계좌
                if let sourceAccount = viewModel.sourceAccount {
                    VStack(spacing: 4) {
                        Text("출금 계좌")
                            .font(typography.footnote)
                            .foregroundColor(ColorTokens.Text.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(sourceAccount.bankName) \(sourceAccount.accountNumber)")
                            .font(typography.body)
                            .foregroundColor(ColorTokens.Text.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Divider()
                        .background(ColorTokens.Border.divider)
                }
                
                // 입금 계좌
                VStack(spacing: 4) {
                    Text("입금 계좌")
                        .font(typography.footnote)
                        .foregroundColor(ColorTokens.Text.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(viewModel.receiverAccount.bankName) \(viewModel.receiverAccount.accountNumber)")
                        .font(typography.body)
                        .foregroundColor(ColorTokens.Text.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if viewModel.fee > 0 {
                    Divider()
                        .background(ColorTokens.Border.divider)
                    
                    // 수수료
                    VStack(spacing: 4) {
                        Text("수수료")
                            .font(typography.footnote)
                            .foregroundColor(ColorTokens.Text.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(formatCurrency(viewModel.fee))
                            .font(typography.body)
                            .foregroundColor(ColorTokens.Text.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(16)
            .background(ColorTokens.Background.card)
            .cornerRadius(16)
            
            // 안내 메시지
            Text("송금 내용을 확인한 후 송금 버튼을 눌러주세요")
                .font(typography.footnote)
                .foregroundColor(ColorTokens.Text.secondary)
            
            Spacer()
            
            // 버튼 영역
            VStack(spacing: 12) {
                TossButton(
                    style: .primary,
                    size: .large,
                    action: {
                        viewModel.send(.transferButtonTapped)
                    }
                ) {
                    Text("송금하기")
                }
                
                TossButton(
                    style: .tertiary,
                    size: .large,
                    action: {
                        viewModel.send(.cancelButtonTapped)
                    }
                ) {
                    Text("취소")
                }
            }
        }
        .padding(16)
        .background(ColorTokens.Background.primary)
        .onAppear {
            viewModel.send(.viewDidLoad)
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
} 
