import Foundation

// MARK: - UseCase 프로토콜
public protocol TransferFundsUseCaseProtocol {
    func execute(
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String
    ) async -> Result<TransferResultEntity, EntityError>
}

public protocol FetchTransferHistoryUseCaseProtocol {
    func execute(accountId: String, limit: Int, offset: Int) async -> Result<[TransferHistoryEntity], EntityError>
}

public protocol FetchFrequentAccountsUseCaseProtocol {
    func execute() async -> Result<[FrequentAccountEntity], EntityError>
}

public protocol AddFrequentAccountUseCaseProtocol {
    func execute(
        bankName: String, 
        accountNumber: String, 
        holderName: String, 
        nickname: String?
    ) async -> Result<FrequentAccountEntity, EntityError>
}

public protocol RemoveFrequentAccountUseCaseProtocol {
    func execute(id: String) async -> Result<Void, EntityError>
}

public protocol UpdateFrequentAccountUseCaseProtocol {
    func execute(
        id: String,
        bankName: String?,
        accountNumber: String?,
        holderName: String?,
        nickname: String?
    ) async -> Result<FrequentAccountEntity, EntityError>
}

// MARK: - UseCase 구현
public final class TransferFundsUseCase: TransferFundsUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    private let accountRepository: AccountRepositoryProtocol
    
    public init(
        transferRepository: TransferRepositoryProtocol,
        accountRepository: AccountRepositoryProtocol
    ) {
        self.transferRepository = transferRepository
        self.accountRepository = accountRepository
    }
    
    public func execute(
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String
    ) async -> Result<TransferResultEntity, EntityError> {
        do {
            guard let fromAccount = try await accountRepository.fetchAccount(withId: fromAccountId) else {
                return .failure(.notFound)
            }
            
            guard fromAccount.balance >= amount else {
                return .failure(.insufficientFunds)
            }
            
            let transferResult = try await transferRepository.transfer(
                fromAccountId: fromAccountId,
                toAccountNumber: toAccountNumber,
                amount: amount,
                description: description
            )
            
            let transaction = TransactionEntity(
                id: UUID().uuidString,
                amount: amount,
                type: .transfer,
                description: "송금: \(toAccountNumber)",
                category: .transfer,
                date: Date(),
                isOutgoing: true,
                account: fromAccount
            )
            
            try await accountRepository.addTransaction(
                transaction,
                toAccountWithId: fromAccountId
            )
            
            return .success(transferResult)
        } catch let error as TransferError {
            switch error {
            case .insufficientFunds:
                return .failure(.insufficientFunds)
            case .invalidAccount:
                return .failure(.invalidInput)
            case .transferLimitExceeded, .dailyLimitExceeded:
                return .failure(.limitExceeded)
            default:
                return .failure(.unexpectedError(error))
            }
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class FetchTransferHistoryUseCase: FetchTransferHistoryUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    
    public init(transferRepository: TransferRepositoryProtocol) {
        self.transferRepository = transferRepository
    }
    
    public func execute(accountId: String, limit: Int, offset: Int) async -> Result<[TransferHistoryEntity], EntityError> {
        do {
            let historyEntities = try await transferRepository.fetchTransferHistory(
                accountId: accountId,
                limit: limit,
                offset: offset
            )
            return .success(historyEntities)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class FetchFrequentAccountsUseCase: FetchFrequentAccountsUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    
    public init(transferRepository: TransferRepositoryProtocol) {
        self.transferRepository = transferRepository
    }
    
    public func execute() async -> Result<[FrequentAccountEntity], EntityError> {
        do {
            let accounts = try await transferRepository.fetchFrequentAccounts()
            return .success(accounts)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class AddFrequentAccountUseCase: AddFrequentAccountUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    
    public init(transferRepository: TransferRepositoryProtocol) {
        self.transferRepository = transferRepository
    }
    
    public func execute(
        bankName: String, 
        accountNumber: String, 
        holderName: String, 
        nickname: String?
    ) async -> Result<FrequentAccountEntity, EntityError> {
        do {
            let account = try await transferRepository.addFrequentAccount(
                bankName: bankName,
                accountNumber: accountNumber,
                holderName: holderName,
                nickname: nickname
            )
            return .success(account)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class RemoveFrequentAccountUseCase: RemoveFrequentAccountUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    
    public init(transferRepository: TransferRepositoryProtocol) {
        self.transferRepository = transferRepository
    }
    
    public func execute(id: String) async -> Result<Void, EntityError> {
        do {
            try await transferRepository.deleteFrequentAccount(id: id)
            return .success(())
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

public final class UpdateFrequentAccountUseCase: UpdateFrequentAccountUseCaseProtocol {
    private let transferRepository: TransferRepositoryProtocol
    
    public init(transferRepository: TransferRepositoryProtocol) {
        self.transferRepository = transferRepository
    }
    
    public func execute(
        id: String,
        bankName: String?,
        accountNumber: String?,
        holderName: String?,
        nickname: String?
    ) async -> Result<FrequentAccountEntity, EntityError> {
        do {
            let account = try await transferRepository.updateFrequentAccount(
                id: id,
                bankName: bankName,
                accountNumber: accountNumber,
                holderName: holderName,
                nickname: nickname
            )
            return .success(account)
        } catch {
            return .failure(.repositoryError(error))
        }
    }
} 
