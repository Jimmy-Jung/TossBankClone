import Foundation
import SwiftData

// 계좌 Repository 인터페이스
public protocol AccountRepositoryProtocol {
    func fetchAccounts() async throws -> [Account]
    func fetchAccount(withId id: String) async throws -> Account?
    func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [Transaction]
    func saveAccount(_ account: Account) async throws
    func deleteAccount(withId id: String) async throws
    func updateAccount(_ account: Account) async throws
    func addTransaction(_ transaction: Transaction, toAccountWithId accountId: String) async throws
}

// SwiftData 기반 Repository 구현
public class AccountRepository: AccountRepositoryProtocol {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() throws {
        self.modelContainer = try SchemaManager.createModelContainer()
        self.modelContext = ModelContext(modelContainer)
    }
    
    public func fetchAccounts() async throws -> [Account] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
                let accounts = try modelContext.fetch(descriptor)
                continuation.resume(returning: accounts)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func fetchAccount(withId id: String) async throws -> Account? {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let predicate = #Predicate<Account> { $0.id == id }
                let descriptor = FetchDescriptor<Account>(predicate: predicate)
                let accounts = try modelContext.fetch(descriptor)
                continuation.resume(returning: accounts.first)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [Transaction] {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let predicate = #Predicate<Transaction> { 
                    $0.account?.id == accountId 
                }
                var descriptor = FetchDescriptor<Transaction>(predicate: predicate)
                descriptor.sortBy = [SortDescriptor(\.date, order: .reverse)]
                descriptor.fetchLimit = limit
                descriptor.fetchOffset = offset
                
                let transactions = try modelContext.fetch(descriptor)
                continuation.resume(returning: transactions)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func saveAccount(_ account: Account) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            modelContext.insert(account)
            
            do {
                try modelContext.save()
                continuation.resume(returning: ())
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func deleteAccount(withId id: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                guard let account = try modelContext.fetch(
                    FetchDescriptor<Account>(predicate: #Predicate { $0.id == id })
                ).first else {
                    throw RepositoryError.itemNotFound
                }
                
                modelContext.delete(account)
                try modelContext.save()
                
                continuation.resume(returning: ())
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func updateAccount(_ account: Account) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try modelContext.save()
                continuation.resume(returning: ())
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func addTransaction(_ transaction: Transaction, toAccountWithId accountId: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                guard let account = try modelContext.fetch(
                    FetchDescriptor<Account>(predicate: #Predicate { $0.id == accountId })
                ).first else {
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
                    } else { // outgoing 또는 reference가 nil인 경우 포함
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
                
                continuation.resume(returning: ())
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    public func generateMockData() {
        MockDataGenerator.generateMockData(in: modelContext)
    }
}

// Repository 오류 유형
public enum RepositoryError: Error {
    case itemNotFound
    case duplicateItem
    case saveFailed
    case deleteFailed
    case fetchFailed
} 