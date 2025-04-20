import Foundation
import DomainModule

/// 모의 데이터 생성기
public class MockDataGenerator {
    /// 모의 계좌 데이터 생성
    /// - Parameter accounts: 계좌 배열 참조
    public static func generateMockData(into accounts: inout [AccountEntity]) {
        // 계좌 데이터 생성
        var checkingAccount = AccountEntity(
            id: "checking-123",
            name: "직장인 통장",
            type: .checking,
            balance: 1250000,
            number: "1234-56-7890123",
            isActive: true,
            updatedAt: Date(),
            transactions: []
        )
        
        var savingsAccount = AccountEntity(
            id: "savings-456",
            name: "비상금 저축",
            type: .savings,
            balance: 5000000,
            number: "9876-54-3210987",
            isActive: true,
            updatedAt: Date(),
            transactions: []
        )
        
        var investmentAccount = AccountEntity(
            id: "investment-789",
            name: "주식 계좌",
            type: .investment,
            balance: 3000000,
            number: "5678-90-1234567",
            isActive: true,
            updatedAt: Date(),
            transactions: []
        )
        
        // 거래내역 생성 및 계좌에 추가
        var transaction1 = TransactionEntity(
            id: "trans-1",
            amount: 50000,
            type: .deposit,
            description: "월급",
            category: .income,
            date: Date().addingTimeInterval(-86400), // 1일 전
            isOutgoing: false,
            account: checkingAccount
        )
        
        let transaction2 = TransactionEntity(
            id: "trans-2",
            amount: 15000,
            type: .withdrawal,
            description: "ATM 출금",
            category: .other,
            date: Date().addingTimeInterval(-43200), // 12시간 전
            isOutgoing: true,
            account: checkingAccount
        )
        
        var transaction3 = TransactionEntity(
            id: "trans-3",
            amount: 30000,
            type: .payment,
            description: "카페",
            category: .food,
            date: Date().addingTimeInterval(-21600), // 6시간 전
            isOutgoing: true,
            account: checkingAccount
        )
        
        var transaction4 = TransactionEntity(
            id: "trans-4",
            amount: 100000,
            type: .transfer,
            description: "비상금 저축",
            category: .transfer,
            date: Date().addingTimeInterval(-7200), // 2시간 전
            isOutgoing: false,
            account: savingsAccount
        )
        
        var transaction5 = TransactionEntity(
            id: "trans-5",
            amount: 100000,
            type: .transfer,
            description: "비상금 저축",
            category: .transfer,
            date: Date().addingTimeInterval(-7200), // 2시간 전
            isOutgoing: false,
            account: checkingAccount
        )
        
        var transaction6 = TransactionEntity(
            id: "trans-6",
            amount: 500000,
            type: .transfer,
            description: "주식 매수",
            category: .transfer,
            date: Date().addingTimeInterval(-172800), // 2일 전
            isOutgoing: true,
            account: investmentAccount
        )
        
        var transaction7 = TransactionEntity(
            id: "trans-7",
            amount: 500000,
            type: .transfer,
            description: "주식 매수",
            category: .transfer,
            date: Date().addingTimeInterval(-172800), // 2일 전
            isOutgoing: true,
            account: checkingAccount
        )
        
        // 거래내역 추가
        checkingAccount.transactions = [transaction1, transaction2, transaction3, transaction5, transaction7]
        savingsAccount.transactions = [transaction4]
        investmentAccount.transactions = [transaction6]
        
        // 계좌 추가
        accounts = [checkingAccount, savingsAccount, investmentAccount]
    }
}

/// 목업 계좌 리포지토리 구현
public class MockAccountRepository: AccountRepositoryProtocol {
    // 인메모리 저장소
    private var accounts: [AccountEntity] = []
    
    /// 초기화
    public init() {
        MockDataGenerator.generateMockData(into: &accounts)
    }
    
    /// 모든 계좌 조회
    public func fetchAccounts() async throws -> [AccountEntity] {
        return accounts.sorted { $0.updatedAt.timeIntervalSince1970 > $1.updatedAt.timeIntervalSince1970 }
    }
    
    /// 단일 계좌 조회
    public func fetchAccount(withId id: String) async throws -> AccountEntity? {
        return accounts.first { $0.id == id }
    }
    
    /// 계좌 저장
    public func saveAccount(_ account: AccountEntity) async throws {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            accounts.append(account)
        }
    }
    
    /// 계좌 삭제
    public func deleteAccount(withId id: String) async throws {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else {
            throw RepositoryError.itemNotFound
        }
        accounts.remove(at: index)
    }
    
    /// 계좌 업데이트
    public func updateAccount(_ account: AccountEntity) async throws {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        } else {
            throw RepositoryError.itemNotFound
        }
    }
    
    /// 계좌 거래내역 조회
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [TransactionEntity] {
        guard let account = accounts.first(where: { $0.id == accountId }),
              let transactions = account.transactions else {
            return []
        }
        
        let sortedTransactions = transactions.sorted { $0.date > $1.date }
        
        if offset < sortedTransactions.count {
            let endIndex = min(offset + limit, sortedTransactions.count)
            return Array(sortedTransactions[offset..<endIndex])
        } else {
            return []
        }
    }
    
    /// 거래내역 추가
    public func addTransaction(_ transaction: TransactionEntity, toAccountWithId accountId: String) async throws {
        var tempTransaction = transaction
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            throw RepositoryError.itemNotFound
        }
        
        var account = accounts[index]
        if account.transactions == nil {
            account.transactions = []
        }
        
        tempTransaction.account = account
        account.transactions?.append(transaction)
        
        // 잔액 업데이트
        switch transaction.type {
        case .deposit:
            account.balance += tempTransaction.amount
        case .withdrawal:
            account.balance -= tempTransaction.amount
        case .transfer:
            if tempTransaction.isOutgoing {
                account.balance -= tempTransaction.amount
            } else { // outgoing 또는 reference가 nil인 경우 포함
                account.balance += tempTransaction.amount
            }
            
        case .payment:
            account.balance -= tempTransaction.amount
        case .fee:
            account.balance -= tempTransaction.amount
        }
        
        account.updatedAt = Date()
        
        accounts[index] = account
    }
} 
