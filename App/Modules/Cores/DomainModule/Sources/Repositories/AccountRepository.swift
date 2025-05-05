import Foundation

// 계좌 Repository 인터페이스
public protocol AccountRepositoryProtocol {
    func fetchAccounts() async throws -> [AccountEntity]
    func fetchAccount(withId id: String) async throws -> AccountEntity?
    func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [TransactionEntity]
    func saveAccount(_ account: AccountEntity) async throws
    func deleteAccount(withId id: String) async throws
    func updateAccount(_ account: AccountEntity) async throws
    func addTransaction(_ transaction: TransactionEntity, toAccountWithId accountId: String) async throws
}

// Repository 오류 유형
public enum RepositoryError: Error {
    case itemNotFound
    case duplicateItem
    case saveFailed
    case deleteFailed
    case fetchFailed
} 
