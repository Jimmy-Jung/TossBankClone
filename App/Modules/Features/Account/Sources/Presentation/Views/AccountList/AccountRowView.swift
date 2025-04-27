//
//  AccountRowView.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct AccountRowView: View {
    let account: AccountEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name)
                .font(.headline)
            
            Text(account.number)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text("\(formatCurrency(account.balance))원")
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding(.vertical, 8)
    }
    
    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: value as NSNumber) ?? "0"
    }
}
