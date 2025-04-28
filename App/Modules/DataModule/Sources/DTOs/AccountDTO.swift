import Foundation
import DomainModule

// DTO 모델
public struct AccountDTO: Codable {
    public let id: String
    public let name: String
    public let type: String
    public let number: String
    public let balance: Decimal
    public let isActive: Bool
    
    public func toEntity() -> AccountEntity {
        return AccountEntity(
            id: id,
            name: name,
            type: AccountType(rawValue: type) ?? .unknown,
            balance: balance,
            number: number,
            isActive: isActive,
            updatedAt: Date(),  // 현재 시간으로 기본값 설정
            transactions: nil   // 기본값 nil
        )
    }
}

public struct TransactionDTO: Codable {
    public let id: String
    public let amount: Decimal
    public let type: String
    public let date: Date
    public let description: String
    public let isOutgoing: Bool
    
    public func toEntity() -> TransactionEntity {
        return TransactionEntity(
            id: id,
            amount: amount,
            type: TransactionType(rawValue: type) ?? .unknown,
            description: description,
            category: .other,  // 기본값으로 .other 사용
            date: date,
            isOutgoing: isOutgoing,
            account: nil       // 기본값 nil
        )
    }
}
