//
//  TransferConfirmViewModel.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SwiftUI
import DomainModule
import SharedModule

public final class TransferConfirmViewModel: AsyncViewModel {
    // Input 열거형 정의
    public enum Input {
        case viewDidLoad
        case transferButtonTapped
        case cancelButtonTapped
    }
    
    // Action 열거형 정의
    public enum Action {
        case loadSourceAccount
        case performTransfer
        case cancelTransfer
    }
    
    // 상태 프로퍼티
    let sourceAccountId: String
    let amount: Double
    let receiverAccount: BankAccount
    @Published var sourceAccount: BankAccount?
    @Published var fee: Double = 0
    @Published var error: Error?
    
    var onTransferButtonTapped: (() -> Void)?
    var onCancelButtonTapped: (() -> Void)?
    
    public init(sourceAccountId: String, amount: Double, receiverAccount: BankAccount) {
        self.sourceAccountId = sourceAccountId
        self.amount = amount
        self.receiverAccount = receiverAccount
    }
    
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return [.loadSourceAccount]
        case .transferButtonTapped:
            return [.performTransfer]
        case .cancelButtonTapped:
            return [.cancelTransfer]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .loadSourceAccount:
            try await loadSourceAccount()
        case .performTransfer:
            try await handleTransferButton()
        case .cancelTransfer:
            try await handleCancelButton()
        }
    }
    
    public func handleError(_ error: Error) async {
        self.error = error
        print("Error: \(error.localizedDescription)")
    }
    
    // MARK: - Action Methods
    
    func loadSourceAccount() async throws {
        // 테스트 데이터
        await MainActor.run {
            sourceAccount = BankAccount(id: sourceAccountId, bankName: "토스뱅크", accountNumber: "1234-56-7890123", balance: 1250000)
        }
    }
    
    func handleTransferButton() async throws {
        if let callback = onTransferButtonTapped {
            await MainActor.run {
                callback()
            }
        }
    }
    
    func handleCancelButton() async throws {
        if let callback = onCancelButtonTapped {
            await MainActor.run {
                callback()
            }
        }
    }
} 