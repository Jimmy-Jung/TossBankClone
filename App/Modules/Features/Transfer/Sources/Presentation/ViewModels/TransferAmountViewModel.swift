//
//  TransferAmountViewModel.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import SharedModule

public final class TransferAmountViewModel: AsyncViewModel {
    // Input 열거형 정의
    public enum Input {
        case viewDidLoad
        case updateAmount(String)
        case updateMemo(String)
        case selectReceiverAccount(BankAccount)
        case toggleAccountSelector(Bool)
        case continueButtonTapped
        case cancelButtonTapped
    }
    
    // Action 열거형 정의
    public enum Action {
        case loadAccount
        case loadRecentAccounts
        case updateAmount(String)
        case updateMemo(String)
        case selectReceiver(BankAccount)
        case toggleAccountSelector(Bool)
        case continueTransfer
        case cancelTransfer
    }
    
    // 상태 프로퍼티
    let accountId: String
    @Published var amount: String = ""
    @Published var memo: String = ""
    @Published var account: BankAccount?
    @Published var selectedReceiverAccount: BankAccount?
    @Published var recentAccounts: [BankAccount] = []
    @Published var showingAccountSelector = false
    @Published var error: Error?
    
    var onContinueButtonTapped: ((Double, BankAccount) -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    
    var isNextButtonEnabled: Bool {
        guard let amount = Double(amount.replacingOccurrences(of: ",", with: "")),
              let selectedAccount = selectedReceiverAccount else {
            return false
        }
        return amount > 0
    }
    
    public init(accountId: String) {
        self.accountId = accountId
    }
    
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return [.loadAccount, .loadRecentAccounts]
        case .updateAmount(let amount):
            return [.updateAmount(amount)]
        case .updateMemo(let memo):
            return [.updateMemo(memo)]
        case .selectReceiverAccount(let account):
            return [.selectReceiver(account)]
        case .toggleAccountSelector(let isShowing):
            return [.toggleAccountSelector(isShowing)]
        case .continueButtonTapped:
            return [.continueTransfer]
        case .cancelButtonTapped:
            return [.cancelTransfer]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .loadAccount:
            try await loadAccount()
        case .loadRecentAccounts:
            try await loadRecentAccounts()
        case .updateAmount(let amount):
            try await updateAmount(amount)
        case .updateMemo(let memo):
            try await updateMemo(memo)
        case .selectReceiver(let account):
            try await selectReceiver(account)
        case .toggleAccountSelector(let isShowing):
            try await toggleAccountSelector(isShowing)
        case .continueTransfer:
            try await handleContinueButton()
        case .cancelTransfer:
            try await handleCancel()
        }
    }
    
    public func handleError(_ error: Error) async {
        self.error = error
        print("Error: \(error.localizedDescription)")
    }
    
    // MARK: - Action Methods
    
    func loadAccount() async throws {
        // 테스트 데이터
        await MainActor.run {
            account = BankAccount(id: accountId, bankName: "토스뱅크", accountNumber: "1234-56-7890123", balance: 1250000)
        }
    }
    
    func loadRecentAccounts() async throws {
        // 테스트 데이터
        await MainActor.run {
            recentAccounts = [
                BankAccount(id: "100", bankName: "신한은행", accountNumber: "110-123-456789", balance: 0),
                BankAccount(id: "101", bankName: "국민은행", accountNumber: "123-45-6789012", balance: 0),
                BankAccount(id: "102", bankName: "우리은행", accountNumber: "1002-456-789012", balance: 0)
            ]
        }
    }
    
    func updateAmount(_ newAmount: String) async throws {
        await MainActor.run {
            amount = newAmount
        }
    }
    
    func updateMemo(_ newMemo: String) async throws {
        await MainActor.run {
            memo = newMemo
        }
    }
    
    func selectReceiver(_ account: BankAccount) async throws {
        await MainActor.run {
            selectedReceiverAccount = account
            showingAccountSelector = false
        }
    }
    
    func toggleAccountSelector(_ isShowing: Bool) async throws {
        await MainActor.run {
            showingAccountSelector = isShowing
        }
    }
    
    func handleContinueButton() async throws {
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: "")),
              let receiverAccount = selectedReceiverAccount else {
            return
        }
        
        if let callback = onContinueButtonTapped {
            await MainActor.run {
                callback(amountValue, receiverAccount)
            }
        }
    }
    
    func handleCancel() async throws {
        if let callback = onCancelButtonTapped {
            await MainActor.run {
                callback()
            }
        }
    }
}
