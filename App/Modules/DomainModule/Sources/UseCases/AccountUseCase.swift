import Foundation

// MARK: - UseCase 프로토콜
public protocol FetchAccountsUseCaseProtocol {
    func execute() async -> Result<[AccountEntity], EntityError>
}

public protocol AddTransactionUseCaseProtocol {
    func execute(accountId: String, transaction: TransactionEntity) async -> Result<Void, EntityError>
}

public protocol FetchAccountDetailUseCaseProtocol {
    func execute(accountId: String) async -> Result<AccountEntity, EntityError>
}

public protocol FetchTransactionsUseCaseProtocol {
    func execute(accountId: String, limit: Int?, offset: Int?) async -> Result<[TransactionEntity], EntityError>
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

public final class FetchAccountDetailUseCase: FetchAccountDetailUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute(accountId: String) async -> Result<AccountEntity, EntityError> {
        do {
            guard let account = try await accountRepository.fetchAccount(withId: accountId) else {
                return .failure(.notFound)
            }
            return .success(account)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class FetchTransactionsUseCase: FetchTransactionsUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute(accountId: String, limit: Int? = 20, offset: Int? = 0) async -> Result<[TransactionEntity], EntityError> {
        do {
            let transactions = try await accountRepository.fetchTransactions(
                forAccountId: accountId,
                limit: limit ?? 20,
                offset: offset ?? 0
            )
            return .success(transactions)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}
