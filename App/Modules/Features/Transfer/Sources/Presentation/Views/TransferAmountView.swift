//
//  TransferAmountView.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import DesignSystem

struct TransferAmountView: View {
    @ObservedObject var viewModel: TransferAmountViewModel
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 금액 입력 섹션
                AmountInputSectionView(
                    amount: $viewModel.amount,
                    account: viewModel.account,
                    onAmountChange: handleAmountChange,
                    onMaxAmountTap: handleMaxAmountTap
                )
                
                // 받는 계좌 선택 섹션
                ReceiverSectionView(
                    selectedAccount: viewModel.selectedReceiverAccount,
                    onSelectAccount: handleToggleAccountSelector
                )
                
                // 메모 입력 섹션
                MemoSectionView(
                    memo: $viewModel.memo,
                    onMemoChange: handleMemoChange
                )
                
                Spacer()
                
                // 다음 버튼
                TossButton(
                    style: .primary,
                    size: .large,
                    action: handleContinueButtonTap
                ) {
                    Text("다음")
                }
                .disabled(!viewModel.isNextButtonEnabled)
                .padding(.top, 30)
            }
            .padding(16)
        }
        .background(ColorTokens.Background.primary)
        .onAppear {
            handleViewLoad()
        }
        .sheet(isPresented: $viewModel.showingAccountSelector) {
            AccountSelectorView(
                accounts: viewModel.recentAccounts,
                onAccountSelected: handleSelectReceiverAccount
            )
        }
    }
    
    // MARK: - 이벤트 핸들러
    private func handleAmountChange(_ newValue: String) {
        viewModel.send(.updateAmount(newValue))
    }
    
    private func handleMaxAmountTap() {
        if let account = viewModel.account {
            viewModel.amount = String(format: "%.0f", account.balance)
            viewModel.send(.updateAmount(viewModel.amount))
        }
    }
    
    private func handleMemoChange(_ newValue: String) {
        viewModel.send(.updateMemo(newValue))
    }
    
    private func handleToggleAccountSelector(_ show: Bool) {
        viewModel.send(.toggleAccountSelector(show))
    }
    
    private func handleSelectReceiverAccount(_ account: BankAccount) {
        viewModel.send(.selectReceiverAccount(account))
    }
    
    private func handleContinueButtonTap() {
        viewModel.send(.continueButtonTapped)
    }
    
    private func handleViewLoad() {
        viewModel.send(.viewDidLoad)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

// MARK: - 금액 입력 섹션
struct AmountInputSectionView: View {
    @FocusState private var isAmountFieldFocused: Bool
    @Binding var amount: String
    let account: BankAccount?
    let onAmountChange: (String) -> Void
    let onMaxAmountTap: () -> Void
    
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        VStack(spacing: 16) {
            Text("얼마를 보낼까요?")
                .font(typography.title3)
                .foregroundColor(ColorTokens.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment: .center) {
                Text("₩")
                    .font(typography.title1)
                    .foregroundColor(ColorTokens.Text.primary)
                
                TextField("0", text: $amount)
                    .font(typography.largeTitle)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(ColorTokens.Text.primary)
                    .focused($isAmountFieldFocused)
                    .onChange(of: amount) { newValue in
                        onAmountChange(newValue)
                    }
            }
            .padding(.vertical, 8)
            
            Divider()
                .background(ColorTokens.Border.divider)
            
            if let account = account {
                HStack {
                    Text("잔액: \(formatCurrency(account.balance))")
                        .font(typography.caption1)
                        .foregroundColor(ColorTokens.Text.secondary)
                    
                    Spacer()
                    
                    Button("전액") {
                        onMaxAmountTap()
                    }
                    .font(typography.caption1)
                    .foregroundColor(ColorTokens.Brand.primary)
                }
            }
        }
        .padding(16)
        .background(ColorTokens.Background.card)
        .cornerRadius(16)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₩"
        return formatter.string(from: NSNumber(value: amount)) ?? "₩0"
    }
}

// MARK: - 받는 계좌 선택 섹션
struct ReceiverSectionView: View {
    let selectedAccount: BankAccount?
    let onSelectAccount: (Bool) -> Void
    @Environment(\.typographyStyle) private var typography
    
    var body: some View {
        VStack(spacing: 12) {
            Text("어디로 보낼까요?")
                .font(typography.title3)
                .foregroundColor(ColorTokens.Text.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let account = selectedAccount {
                // 선택된 계좌 표시
                ReceiverAccountRow(account: account)
                    .onTapGesture {
                        onSelectAccount(true)
                    }
            } else {
                // 계좌 선택 버튼
                Button(action: {
                    onSelectAccount(true)
                }) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("받을 계좌 선택하기")
                            .font(.body)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(16)
                }
            }
        }
    }
}

// MARK: - 메모 입력 섹션
struct MemoSectionView: View {
    @Binding var memo: String
    let onMemoChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("받는 분에게 표시될 메모")
                .font(.body)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            TextField("(선택) 최대 20자", text: $memo)
                .padding(16)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(16)
                .onChange(of: memo) { newValue in
                    onMemoChange(newValue)
                }
        }
    }
}

struct ReceiverAccountRow: View {
    let account: BankAccount
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(account.bankName)
                    .font(.body)
                    .fontWeight(.medium)
                
                Text(account.accountNumber)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
    }
} 
