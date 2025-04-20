import Foundation

// MARK: - UseCase 프로토콜
public protocol FetchAccountsUseCaseProtocol {
    func execute() async -> Result<[AccountEntity], EntityError>
}

public protocol FetchAccountDetailsUseCaseProtocol {
    func execute(accountId: String) async -> Result<AccountDetailsEntity, EntityError>
}

public protocol AddTransactionUseCaseProtocol {
    func execute(accountId: String, transaction: TransactionEntity) async -> Result<Void, EntityError>
}

// MARK: - UseCase 구현
public final class FetchAccountsUseCase: FetchAccountsUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute() async -> Result<[AccountEntity], EntityError> {
        do {
            let accounts = try await accountRepository.fetchAccounts()
            return .success(accounts)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class FetchAccountDetailsUseCase: FetchAccountDetailsUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute(accountId: String) async -> Result<AccountDetailsEntity, EntityError> {
        do {
            guard let account = try await accountRepository.fetchAccount(withId: accountId) else {
                return .failure(.notFound)
            }
            
            let transactions = try await accountRepository.fetchTransactions(
                forAccountId: accountId, 
                limit: 20, 
                offset: 0
            )
            return .success(
                AccountDetailsEntity(
                    account: account,
                    recentTransactions: transactions
                )
            )
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class AddTransactionUseCase: AddTransactionUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute(accountId: String, transaction: TransactionEntity) async -> Result<Void, EntityError> {
        do {
            try await accountRepository.addTransaction(
                transaction,
                toAccountWithId: accountId
            )
            return .success(())
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

// MARK: - EntityError 정의
public enum EntityError: Error {
    case notFound
    case invalidInput
    case insufficientFunds
    case limitExceeded
    case repositoryError(Error)
    case unexpectedError(Error)
}
