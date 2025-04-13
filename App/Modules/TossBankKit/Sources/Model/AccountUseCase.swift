import Foundation

// MARK: - UseCase 프로토콜
public protocol FetchAccountsUseCaseProtocol {
    func execute() async -> Result<[AccountDomain], DomainError>
}

public protocol FetchAccountDetailsUseCaseProtocol {
    func execute(accountId: String) async -> Result<AccountDetailsDomain, DomainError>
}

public protocol AddTransactionUseCaseProtocol {
    func execute(accountId: String, transaction: TransactionDomain) async -> Result<Void, DomainError>
}

// MARK: - UseCase 구현
public final class FetchAccountsUseCase: FetchAccountsUseCaseProtocol {
    private let accountRepository: AccountRepositoryProtocol
    
    public init(accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
    }
    
    public func execute() async -> Result<[AccountDomain], DomainError> {
        do {
            let accounts = try await accountRepository.fetchAccounts()
            return .success(accounts.map { $0.toDomain() })
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
    
    public func execute(accountId: String) async -> Result<AccountDetailsDomain, DomainError> {
        do {
            guard let account = try await accountRepository.fetchAccount(withId: accountId) else {
                return .failure(.notFound)
            }
            
            let transactions = try await accountRepository.fetchTransactions(
                forAccountId: accountId, 
                limit: 20, 
                offset: 0
            )
            
            let accountDomain = account.toDomain()
            let transactionsDomain = transactions.map { $0.toDomain() }
            
            return .success(
                AccountDetailsDomain(
                    account: accountDomain,
                    recentTransactions: transactionsDomain
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
    
    public func execute(accountId: String, transaction: TransactionDomain) async -> Result<Void, DomainError> {
        do {
            let transactionEntity = Transaction(
                amount: transaction.amount,
                type: TransactionType(rawValue: transaction.type.rawValue) ?? .transfer,
                description: transaction.description,
                category: TransactionCategory(rawValue: transaction.category.rawValue) ?? .other,
                date: transaction.date
            )
            
            if let metadata = transaction.metadata {
                transactionEntity.metadata = TransactionMetadata(
                    location: metadata.location,
                    merchantName: metadata.merchantName,
                    merchantLogo: metadata.merchantLogo,
                    reference: metadata.reference
                )
            }
            
            try await accountRepository.addTransaction(transactionEntity, toAccountWithId: accountId)
            return .success(())
        } catch {
            return .failure(.repositoryError(error))
        }
    }
}

// MARK: - 도메인 엔티티
public struct AccountDomain {
    public let id: String
    public let name: String
    public let type: AccountTypeDomain
    public let balance: Decimal
    public let number: String
    public let isActive: Bool
    
    public init(
        id: String,
        name: String,
        type: AccountTypeDomain,
        balance: Decimal,
        number: String,
        isActive: Bool
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.number = number
        self.isActive = isActive
    }
}

public struct TransactionDomain {
    public let id: String
    public let amount: Decimal
    public let type: TransactionTypeDomain
    public let description: String
    public let category: TransactionCategoryDomain
    public let date: Date
    public let metadata: TransactionMetadataDomain?
    
    public init(
        id: String,
        amount: Decimal,
        type: TransactionTypeDomain,
        description: String,
        category: TransactionCategoryDomain,
        date: Date,
        metadata: TransactionMetadataDomain?
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.description = description
        self.category = category
        self.date = date
        self.metadata = metadata
    }
}

public struct TransactionMetadataDomain {
    public let location: String?
    public let merchantName: String?
    public let merchantLogo: String?
    public let reference: String?
    
    public init(
        location: String?,
        merchantName: String?,
        merchantLogo: String?,
        reference: String?
    ) {
        self.location = location
        self.merchantName = merchantName
        self.merchantLogo = merchantLogo
        self.reference = reference
    }
}

public struct AccountDetailsDomain {
    public let account: AccountDomain
    public let recentTransactions: [TransactionDomain]
    
    public init(account: AccountDomain, recentTransactions: [TransactionDomain]) {
        self.account = account
        self.recentTransactions = recentTransactions
    }
}

public enum AccountTypeDomain: String {
    case checking = "CHECKING"
    case savings = "SAVINGS"
    case investment = "INVESTMENT"
    case loan = "LOAN"
}

public enum TransactionTypeDomain: String {
    case deposit = "DEPOSIT"
    case withdrawal = "WITHDRAWAL"
    case transfer = "TRANSFER"
    case payment = "PAYMENT"
    case fee = "FEE"
}

public enum TransactionCategoryDomain: String {
    case food = "FOOD"
    case transportation = "TRANSPORTATION"
    case housing = "HOUSING"
    case entertainment = "ENTERTAINMENT"
    case shopping = "SHOPPING"
    case utilities = "UTILITIES"
    case health = "HEALTH"
    case education = "EDUCATION"
    case income = "INCOME"
    case transfer = "TRANSFER"
    case other = "OTHER"
}

public enum DomainError: Error {
    case repositoryError(Error)
    case validationError(String)
    case notFound
    case unauthorized
    case networkError
}

// MARK: - 매핑 확장
extension Account {
    func toDomain() -> AccountDomain {
        return AccountDomain(
            id: id,
            name: name,
            type: AccountTypeDomain(rawValue: type.rawValue) ?? .checking,
            balance: balance,
            number: number,
            isActive: isActive
        )
    }
}

extension Transaction {
    func toDomain() -> TransactionDomain {
        let metadataDomain = metadata.map {
            TransactionMetadataDomain(
                location: $0.location,
                merchantName: $0.merchantName,
                merchantLogo: $0.merchantLogo,
                reference: $0.reference
            )
        }
        
        return TransactionDomain(
            id: id,
            amount: amount,
            type: TransactionTypeDomain(rawValue: type.rawValue) ?? .transfer,
            description: desc,
            category: TransactionCategoryDomain(rawValue: category.rawValue) ?? .other,
            date: date,
            metadata: metadataDomain
        )
    }
} 
