import Foundation
import SwiftData

/// 메모리 기반 Mock 계좌 Repository 구현
public class MockAccountRepository: AccountRepositoryProtocol {
    private var accounts: [Account] = []
    private var transactions: [Transaction] = []
    private var metadata: [TransactionMetadata] = []
    
    public init(populateWithMockData: Bool = true) {
        if populateWithMockData {
            self.populateMockData()
        }
    }
    
    // MARK: - Repository 메서드 구현
    public func fetchAccounts() async throws -> [Account] {
        return accounts
    }
    
    public func fetchAccount(withId id: String) async throws -> Account? {
        return accounts.first { $0.id == id }
    }
    
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [Transaction] {
        let accountTransactions = transactions.filter { $0.account?.id == accountId }
        let sortedTransactions = accountTransactions.sorted { $0.date > $1.date }
        
        // offset과 limit 적용
        let startIndex = min(offset, sortedTransactions.count)
        let endIndex = min(startIndex + limit, sortedTransactions.count)
        
        guard startIndex < endIndex else {
            return []
        }
        
        return Array(sortedTransactions[startIndex..<endIndex])
    }
    
    public func saveAccount(_ account: Account) async throws {
        // 기존 계정 업데이트 또는 새 계정 추가
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
    }
    
    public func deleteAccount(withId id: String) async throws {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.itemNotFound
        }
        
        // 계정에 연결된 모든 트랜잭션도 삭제
        transactions.removeAll { $0.account?.id == id }
        
        // 계정 삭제
        accounts.remove(at: index)
    }
    
    public func updateAccount(_ account: Account) async throws {
        guard let index = accounts.firstIndex(where: { $0.id == account.id }) else {
            throw RepositoryError.itemNotFound
        }
        
        accounts[index] = account
    }
    
    public func addTransaction(_ transaction: Transaction, toAccountWithId accountId: String) async throws {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw RepositoryError.itemNotFound
        }
        
        // 트랜잭션 메타데이터 저장
        if let metadata = transaction.metadata {
            self.metadata.append(metadata)
        }
        
        // 트랜잭션에 계정 연결
        transaction.account = accounts[accountIndex]
        
        // 트랜잭션 추가
        transactions.append(transaction)
        
        // 계정의 트랜잭션 목록 업데이트
        if accounts[accountIndex].transactions == nil {
            accounts[accountIndex].transactions = []
        }
        accounts[accountIndex].transactions?.append(transaction)
        
        // 잔액 업데이트
        switch transaction.type {
        case .deposit:
            accounts[accountIndex].balance += transaction.amount
        case .withdrawal:
            accounts[accountIndex].balance -= transaction.amount
        case .transfer:
            if transaction.metadata?.reference == "incoming" {
                accounts[accountIndex].balance += transaction.amount
            } else {
                accounts[accountIndex].balance -= transaction.amount
            }
        case .payment:
            accounts[accountIndex].balance -= transaction.amount
        case .fee:
            accounts[accountIndex].balance -= transaction.amount
        }
        
        // 계정 업데이트 시간 갱신
        accounts[accountIndex].updatedAt = Date()
    }
    
    // MARK: - 모의 데이터 생성
    private func populateMockData() {
        // 계좌 생성
        let checkingAccount = Account(
            name: "일상 계좌",
            type: .checking,
            balance: 2_500_000,
            number: "123-456-789",
            isActive: true
        )
        
        let savingsAccount = Account(
            name: "저축 계좌",
            type: .savings,
            balance: 15_000_000,
            number: "123-456-790",
            isActive: true
        )
        
        let investmentAccount = Account(
            name: "투자 계좌",
            type: .investment,
            balance: 5_000_000,
            number: "123-456-791",
            isActive: true
        )
        
        accounts.append(contentsOf: [checkingAccount, savingsAccount, investmentAccount])
        
        // 트랜잭션 생성
        let calendar = Calendar.current
        
        // 일상 계좌 트랜잭션
        let depositMetadata = TransactionMetadata(
            merchantName: "토스뱅크",
            reference: "incoming"
        )
        metadata.append(depositMetadata)
        
        let deposit = Transaction(
            amount: 1_000_000,
            type: .deposit,
            description: "급여",
            category: .income,
            date: calendar.date(byAdding: .day, value: -5, to: Date())!,
            account: checkingAccount,
            metadata: depositMetadata
        )
        
        let withdrawalMetadata = TransactionMetadata(
            location: "서울시 강남구",
            merchantName: "신한은행 ATM"
        )
        metadata.append(withdrawalMetadata)
        
        let withdrawal = Transaction(
            amount: 50_000,
            type: .withdrawal,
            description: "ATM 출금",
            category: .other,
            date: calendar.date(byAdding: .day, value: -3, to: Date())!,
            account: checkingAccount,
            metadata: withdrawalMetadata
        )
        
        let paymentMetadata = TransactionMetadata(
            location: "서울시 강남구",
            merchantName: "스타벅스",
            merchantLogo: "starbucks_logo"
        )
        metadata.append(paymentMetadata)
        
        let payment = Transaction(
            amount: 15_000,
            type: .payment,
            description: "스타벅스 결제",
            category: .food,
            date: calendar.date(byAdding: .day, value: -2, to: Date())!,
            account: checkingAccount,
            metadata: paymentMetadata
        )
        
        let transferOutMetadata = TransactionMetadata(
            merchantName: "토스뱅크",
            reference: "outgoing"
        )
        metadata.append(transferOutMetadata)
        
        let transferOut = Transaction(
            amount: 200_000,
            type: .transfer,
            description: "저축 계좌로 이체",
            category: .transfer,
            date: calendar.date(byAdding: .day, value: -1, to: Date())!,
            account: checkingAccount,
            metadata: transferOutMetadata
        )
        
        // 저축 계좌 트랜잭션
        let transferInMetadata = TransactionMetadata(
            merchantName: "토스뱅크",
            reference: "incoming"
        )
        metadata.append(transferInMetadata)
        
        let transferIn = Transaction(
            amount: 200_000,
            type: .transfer,
            description: "일상 계좌에서 이체",
            category: .transfer,
            date: calendar.date(byAdding: .day, value: -1, to: Date())!,
            account: savingsAccount,
            metadata: transferInMetadata
        )
        
        // 트랜잭션 추가
        transactions.append(contentsOf: [deposit, withdrawal, payment, transferOut, transferIn])
        
        // 계좌에 트랜잭션 연결
        checkingAccount.transactions = [deposit, withdrawal, payment, transferOut]
        savingsAccount.transactions = [transferIn]
        investmentAccount.transactions = []
        
        // 계좌 잔액 계산 (실제로는 이미 위에서 잔액을 설정했지만, 일관성을 위해)
        checkingAccount.balance = 2_500_000
        savingsAccount.balance = 15_000_000
        investmentAccount.balance = 5_000_000
    }
} 