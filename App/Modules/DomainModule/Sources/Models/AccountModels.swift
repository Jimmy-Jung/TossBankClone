import Foundation
import SwiftData

@Model
public final class Account {
    // 기본 정보
    @Attribute(.unique) public var id: String
    public var name: String
    public var type: AccountType
    public var balance: Decimal
    public var number: String
    public var isActive: Bool
    
    // 관계
    @Relationship(deleteRule: .cascade) public var transactions: [Transaction]? = []
    
    // 메타데이터
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        type: AccountType,
        balance: Decimal,
        number: String,
        isActive: Bool = true,
        transactions: [Transaction]? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.balance = balance
        self.number = number
        self.isActive = isActive
        self.transactions = transactions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum AccountType: String, Codable {
    case checking = "CHECKING"
    case savings = "SAVINGS"
    case investment = "INVESTMENT"
    case loan = "LOAN"
}

@Model
public final class Transaction {
    // 기본 정보
    @Attribute(.unique) public var id: String
    public var amount: Decimal
    public var type: TransactionType
    public var desc: String
    public var category: TransactionCategory
    public var date: Date
    
    // 관계
    @Relationship public var account: Account?
    
    // 추가 정보
    public var metadata: TransactionMetadata?
    
    public init(
        id: String = UUID().uuidString,
        amount: Decimal,
        type: TransactionType,
        description: String,
        category: TransactionCategory,
        date: Date = Date(),
        account: Account? = nil,
        metadata: TransactionMetadata? = nil
    ) {
        self.id = id
        self.amount = amount
        self.type = type
        self.desc = description
        self.category = category
        self.date = date
        self.account = account
        self.metadata = metadata
    }
}

public enum TransactionType: String, Codable {
    case deposit = "DEPOSIT"
    case withdrawal = "WITHDRAWAL"
    case transfer = "TRANSFER"
    case payment = "PAYMENT"
    case fee = "FEE"
}

public enum TransactionCategory: String, Codable {
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

@Model
public final class TransactionMetadata {
    @Attribute(.unique) public var id: String
    public var location: String?
    public var merchantName: String?
    public var merchantLogo: String?
    public var reference: String?
    
    public init(
        id: String = UUID().uuidString,
        location: String? = nil,
        merchantName: String? = nil,
        merchantLogo: String? = nil,
        reference: String? = nil
    ) {
        self.id = id
        self.location = location
        self.merchantName = merchantName
        self.merchantLogo = merchantLogo
        self.reference = reference
    }
} 