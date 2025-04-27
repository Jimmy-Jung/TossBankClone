//
//  AccountDetailViewModel.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/26.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import DomainModule
import SharedModule
import DataModule
import DomainModule

public final class AccountDetailViewModel: AsyncViewModel {
    // Input 열거형 정의
    public enum Input {
        case viewDidLoad
        case refresh
        case transferButtonTapped
    }
    
    // Action 열거형 정의
    public enum Action {
        case fetchAccountDetail
        case updateAccountDetail(AccountEntity)
        case updateTransactions([TransactionEntity])
        case requestTransfer
    }
    
    // 상태 프로퍼티
    @Published var account: AccountEntity?
    @Published var transactions: [TransactionEntity] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    var onTransferRequested: (() -> Void)?
    
    private let accountId: String
    private let fetchAccountDetailUseCase: FetchAccountDetailUseCaseProtocol
    private let fetchTransactionsUseCase: FetchTransactionsUseCaseProtocol
    
    init(accountId: String,
         fetchAccountDetailUseCase: FetchAccountDetailUseCaseProtocol,
         fetchTransactionsUseCase: FetchTransactionsUseCaseProtocol) {
        self.accountId = accountId
        self.fetchAccountDetailUseCase = fetchAccountDetailUseCase
        self.fetchTransactionsUseCase = fetchTransactionsUseCase
    }
    
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad, .refresh:
            return [.fetchAccountDetail]
        case .transferButtonTapped:
            return [.requestTransfer]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .fetchAccountDetail:
            try await fetchAccountDetail()
        case .updateAccountDetail(let account):
            try await updateAccountDetail(account)
        case .updateTransactions(let transactions):
            try await updateTransactions(transactions)
        case .requestTransfer:
            try await requestTransfer()
        }
    }
    
    public func handleError(_ error: Error) async {
        self.error = error
        isLoading = false
        print("Error: \(error.localizedDescription)")
    }
    
    // MARK: - 내부 메서드
    
    func fetchAccountDetail() async throws {
        isLoading = true
        error = nil
        
        // 계좌 상세 정보 로드
        let accountResult = await fetchAccountDetailUseCase.execute(accountId: accountId)
        
        switch accountResult {
        case .success(let fetchedAccount):
            await updateAccount(fetchedAccount)
            
            // 거래 내역 로드
            let transactionsResult = await fetchTransactionsUseCase.execute(accountId: accountId, limit: 10, offset: 0)
            switch transactionsResult {
            case .success(let fetchedTransactions):
                try await updateTransactions(fetchedTransactions)
            case .failure(let entityError):
                await handleError(entityError)
            }
            
        case .failure(let entityError):
            await handleError(entityError)
        }
    }
    
    func updateAccount(_ account: AccountEntity) async {
        self.account = account
    }
    
    func updateAccountDetail(_ account: AccountEntity) async throws {
        self.account = account
        isLoading = false
    }
    
    func updateTransactions(_ transactions: [TransactionEntity]) async throws {
        self.transactions = transactions
        isLoading = false
    }
    
    func requestTransfer() async throws {
        onTransferRequested?()
    }
}
