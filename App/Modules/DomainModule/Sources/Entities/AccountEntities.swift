import Foundation

// MARK: - Account 관련 엔티티
public struct AccountEntity {
    public let id: String
    public var name: String
    public var type: AccountType
    public var balance: Decimal
    public var number: String
    public var isActive: Bool
    public var updatedAt: Date
    public var transactions: [TransactionEntity]?
    
    public init(
        id: String,
        name: String,
        type: AccountType,
        balance: Decimal,
        number: String,
        isActive: Bool,
        updatedAt: Date,
        transactions: [TransactionEntity]?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.number = number
        self.isActive = isActive
        self.updatedAt = updatedAt
        self.transactions = transactions
    }
}

public enum AccountType: String, Codable {
    case checking = "CHECKING"
    case savings = "SAVINGS"
    case investment = "INVESTMENT"
    case loan = "LOAN"
    case unknown = "UNKNOWN"
}

// MARK: - Transaction 관련 엔티티
public struct TransactionEntity {
    public let id: String
    public let amount: Decimal
    public let type: TransactionType
    public let description: String
    public let category: TransactionCategoryEntity
    public let date: Date
    public let isOutgoing: Bool
    public var account: AccountEntity?
    
    public init(
        id: String,
        amount: Decimal,
        type: TransactionType,
        description: String,
        category: TransactionCategoryEntity,
        date: Date,
        isOutgoing: Bool,
        account: AccountEntity?
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.description = description
        self.category = category
        self.date = date
        self.isOutgoing = isOutgoing
        self.account = account
    }
}

public enum TransactionType: String, Codable {
    case deposit = "DEPOSIT"
    case withdrawal = "WITHDRAWAL"
    case transfer = "TRANSFER"
    case payment = "PAYMENT"
    case fee = "FEE"
    case unknown = "UNKNOWN"
}

public enum TransactionCategoryEntity: String, Codable {
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

// MARK: - Account 세부 정보 엔티티
public struct AccountDetailsEntity {
    public let account: AccountEntity
    public let recentTransactions: [TransactionEntity]
    
    public init(account: AccountEntity, recentTransactions: [TransactionEntity]) {
        self.account = account
        self.recentTransactions = recentTransactions
    }
}
