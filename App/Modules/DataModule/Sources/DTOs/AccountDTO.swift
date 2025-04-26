import Foundation
import DomainModule

// DTO 모델
struct AccountDTO: Codable {
    let id: String
    let name: String
    let type: String
    let number: String
    let balance: Decimal
    let isActive: Bool
    
    func toEntity() -> AccountEntity {
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

struct TransactionDTO: Codable {
    let id: String
    let amount: Decimal
    let type: String
    let date: Date
    let description: String
    let isOutgoing: Bool
    
    func toEntity() -> TransactionEntity {
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
