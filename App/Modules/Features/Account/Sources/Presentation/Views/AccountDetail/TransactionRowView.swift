//
//  TransactionRowView.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct TransactionRow: View {
    let transaction: TransactionEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(transaction.description)
                    .font(.headline)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("\(formatCurrency(transaction.amount))원")
                .font(.subheadline)
                .foregroundColor(transaction.amount >= 0 ? .blue : .primary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSNumber) ?? "0"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
