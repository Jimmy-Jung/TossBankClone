//
//  AccountSelectorView.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct AccountSelectorView: View {
    let accounts: [BankAccount]
    let onAccountSelected: (BankAccount) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        NavigationView {
            List(accounts) { account in
                Button(action: {
                    onAccountSelected(account)
                    dismiss()
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(account.bankName)
                                .font(typography.bodyMedium)
                                .foregroundColor(ColorTokens.Text.primary)
                            
                            Text(account.accountNumber)
                                .font(typography.footnote)
                                .foregroundColor(ColorTokens.Text.secondary)
                        }
                    }
                }
            }
            .navigationTitle("계좌 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(ColorTokens.Brand.primary)
                }
            }
            .background(ColorTokens.Background.primary)
        }
    }
} 