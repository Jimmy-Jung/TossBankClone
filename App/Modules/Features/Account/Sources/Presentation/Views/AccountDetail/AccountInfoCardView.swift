//
//  AccountInfoCardView.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct AccountInfoCardView: View {
    let account: AccountEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(account.name)
                .font(.headline)
            
            Text(account.number)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(formatCurrency(account.balance))원")
                .font(.title)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSNumber) ?? "0"
    }
}
