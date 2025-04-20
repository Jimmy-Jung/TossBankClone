import Foundation

// MARK: - Transfer Result Entity
public struct TransferResultEntity: Equatable {
    public let transactionId: String
    public let fromAccountId: String
    public let toAccountNumber: String
    public let amount: Decimal
    public let fee: Decimal?
    public let status: TransferStatusEntity
    public let timestamp: Date
    
    public init(
        transactionId: String,
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        fee: Decimal?,
        status: TransferStatusEntity,
        timestamp: Date
    ) {
        self.transactionId = transactionId
        self.fromAccountId = fromAccountId
        self.toAccountNumber = toAccountNumber
        self.amount = amount
        self.fee = fee
        self.status = status
        self.timestamp = timestamp
    }
}

// MARK: - Transfer Status Entity
public enum TransferStatusEntity: String, Codable {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case cancelled = "CANCELLED"
}

// MARK: - Transfer History Entity
public struct TransferHistoryEntity: Identifiable, Equatable {
    public let id: String
    public let fromAccountId: String
    public let toAccountId: String?
    public let toAccountNumber: String
    public let toAccountName: String?
    public let amount: Decimal
    public let description: String
    public let timestamp: Date
    public let status: TransferStatusEntity
    
    public init(
        id: String,
        fromAccountId: String,
        toAccountId: String? = nil,
        toAccountNumber: String,
        toAccountName: String?,
        amount: Decimal,
        description: String,
        timestamp: Date,
        status: TransferStatusEntity
    ) {
        self.id = id
        self.fromAccountId = fromAccountId
        self.toAccountId = toAccountId
        self.toAccountNumber = toAccountNumber
        self.toAccountName = toAccountName
        self.amount = amount
        self.description = description
        self.timestamp = timestamp
        self.status = status
    }
}

// MARK: - Frequent Account Entity
public struct FrequentAccountEntity: Identifiable, Equatable {
    public let id: String
    public let bankName: String
    public let accountNumber: String
    public let holderName: String
    public let nickname: String?
    public let lastUsed: Date?
    
    public init(
        id: String = UUID().uuidString,
        bankName: String,
        accountNumber: String,
        holderName: String,
        nickname: String? = nil,
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.bankName = bankName
        self.accountNumber = accountNumber
        self.holderName = holderName
        self.nickname = nickname
        self.lastUsed = lastUsed
    }
}
