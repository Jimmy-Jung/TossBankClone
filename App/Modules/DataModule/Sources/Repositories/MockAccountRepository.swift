import Foundation
import SwiftData
import DomainModule

/// 테스트용 가상 데이터 생성기
public final class MockDataGenerator {
    /// 모델 컨텍스트에 가상 데이터 생성
    /// - Parameter context: 모델 컨텍스트
    public static func generateMockData(in context: ModelContext) {
        // 가상 계좌 생성
        let checkingAccount = Account(
            id: "check-001",
            name: "기본 입출금 통장",
            type: .checking,
            balance: 1_250_000,
            number: "352-1234-5678-01",
            isActive: true
        )
        
        let savingsAccount = Account(
            id: "save-001",
            name: "비상금 저축",
            type: .savings,
            balance: 5_000_000,
            number: "212-8765-4321-02",
            isActive: true
        )
        
        let loanAccount = Account(
            id: "loan-001",
            name: "생활대출",
            type: .loan,
            balance: -2_000_000,
            number: "422-9966-8877-03",
            isActive: true
        )
        
        // 가상 거래 내역 생성
        let transactions1 = [
            createTransaction(
                account: checkingAccount,
                amount: 50000,
                type: .deposit,
                description: "급여",
                category: .income,
                dayOffset: -1,
                merchant: "토스뱅크 (주)"
            ),
            createTransaction(
                account: checkingAccount,
                amount: -15000,
                type: .payment,
                description: "스타벅스",
                category: .food,
                dayOffset: -1,
                location: "서울시 강남구",
                merchant: "스타벅스"
            ),
            createTransaction(
                account: checkingAccount,
                amount: -30000,
                type: .payment,
                description: "식사",
                category: .food,
                dayOffset: -2,
                location: "서울시 강남구",
                merchant: "맛있는 레스토랑"
            ),
            createTransaction(
                account: checkingAccount,
                amount: -50000,
                type: .transfer,
                description: "친구에게 송금",
                category: .transfer,
                dayOffset: -3
            ),
            createTransaction(
                account: checkingAccount,
                amount: -9900,
                type: .payment,
                description: "넷플릭스 구독",
                category: .entertainment,
                dayOffset: -5,
                merchant: "넷플릭스"
            )
        ]
        
        let transactions2 = [
            createTransaction(
                account: savingsAccount,
                amount: 500000,
                type: .deposit,
                description: "저축",
                category: .transfer,
                dayOffset: -30
            ),
            createTransaction(
                account: savingsAccount,
                amount: 300000,
                type: .deposit,
                description: "저축",
                category: .transfer,
                dayOffset: -60
            )
        ]
        
        let transactions3 = [
            createTransaction(
                account: loanAccount,
                amount: -50000,
                type: .fee,
                description: "이자",
                category: .other,
                dayOffset: -10
            )
        ]
        
        // 데이터 삽입
        [checkingAccount, savingsAccount, loanAccount].forEach { context.insert($0) }
        
        // 저장
        do {
            try context.save()
        } catch {
            print("Mock 데이터 저장 오류: \(error)")
        }
    }
    
    /// 가상 거래내역 생성
    private static func createTransaction(
        account: Account,
        amount: Decimal,
        type: TransactionType,
        description: String,
        category: TransactionCategory,
        dayOffset: Int,
        location: String? = nil,
        merchant: String? = nil
    ) -> Transaction {
        let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: Date())!
        
        let transaction = Transaction(
            id: UUID().uuidString,
            amount: amount,
            type: type,
            description: description,
            category: category,
            date: date,
            account: account
        )
        
        if location != nil || merchant != nil {
            transaction.metadata = TransactionMetadata(
                location: location,
                merchantName: merchant,
                merchantLogo: merchant != nil ? "\(merchant!.lowercased().replacingOccurrences(of: " ", with: "_"))_logo" : nil
            )
        }
        
        return transaction
    }
}

/// 목(Mock) 계좌 저장소 구현
public class MockAccountRepository: AccountRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() throws {
        // 인메모리 컨테이너 생성
        let schema = Schema([
            Account.self,
            Transaction.self,
            TransactionMetadata.self
        ])
        
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        self.modelContainer = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )
        self.modelContext = ModelContext(modelContainer)
        
        // 가상 데이터 생성
        MockDataGenerator.generateMockData(in: modelContext)
    }
    
    public func fetchAccounts() async throws -> [Account] {
        let descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetchAccount(withId id: String) async throws -> Account? {
        let predicate = #Predicate<Account> { $0.id == id }
        let descriptor = FetchDescriptor<Account>(predicate: predicate)
        let accounts = try modelContext.fetch(descriptor)
        return accounts.first
    }
    
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [Transaction] {
        let predicate = #Predicate<Transaction> { $0.account?.id == accountId }
        var descriptor = FetchDescriptor<Transaction>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
        descriptor.fetchLimit = limit
        descriptor.fetchOffset = offset
        
        return try modelContext.fetch(descriptor)
    }
    
    public func saveAccount(_ account: Account) async throws {
        modelContext.insert(account)
        try modelContext.save()
    }
    
    public func deleteAccount(withId id: String) async throws {
        guard let account = try await fetchAccount(withId: id) else {
            throw RepositoryError.itemNotFound
        }
        
        modelContext.delete(account)
        try modelContext.save()
    }
    
    public func updateAccount(_ account: Account) async throws {
        try modelContext.save()
    }
    
    public func addTransaction(_ transaction: Transaction, toAccountWithId accountId: String) async throws {
        guard let account = try await fetchAccount(withId: accountId) else {
            throw RepositoryError.itemNotFound
        }
        
        if account.transactions == nil {
            account.transactions = []
        }
        
        transaction.account = account
        account.transactions?.append(transaction)
        
        // 잔액 업데이트
        switch transaction.type {
        case .deposit:
            account.balance += transaction.amount
        case .withdrawal:
            account.balance -= transaction.amount
        case .transfer:
            if transaction.metadata?.reference == "incoming" {
                account.balance += transaction.amount
            } else {
                account.balance -= transaction.amount
            }
        case .payment:
            account.balance -= transaction.amount
        case .fee:
            account.balance -= transaction.amount
        }
        
        account.updatedAt = Date()
        
        modelContext.insert(transaction)
        try modelContext.save()
    }
} 