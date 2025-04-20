import Foundation
import DomainModule

/// 계좌 DTO 모델
public struct AccountDTO: Decodable {
    let id: String
    let name: String
    let accountNumber: String
    let accountType: String
    let balance: Decimal
    let isActive: Bool
    let updateAt: String?
    let transactions: [TransactionDTO]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case accountNumber = "account_number"
        case accountType = "account_type"
        case balance
        case isActive = "is_active"
        case updateAt = "updated_at"
        case transactions
    }
    
    /// 도메인 모델로 변환
    func toEntity() -> AccountEntity {
        return AccountEntity(
            id: id,
            name: name,
            type: mapAccountType(accountType),
            balance: balance,
            number: accountNumber,
            isActive: isActive,
            updatedAt: updateAt.flatMap { ISO8601DateFormatter().date(from: $0)
            } ?? Date(),
            transactions: transactions?.map { $0.toEntity() } ?? []
        )
    }
    
    /// 계좌 타입 문자열을 AccountType으로 매핑
    private func mapAccountType(_ typeString: String) -> AccountTypeEntity {
        switch typeString.uppercased() {
        case "CHECKING":
            return .checking
        case "SAVINGS":
            return .savings
        case "INVESTMENT":
            return .investment
        case "LOAN":
            return .loan
        default:
            return .checking
        }
    }
}

/// 거래 DTO 모델
public struct TransactionDTO: Decodable {
    let id: String
    let accountId: String
    let amount: Decimal
    let type: String
    let category: String?
    let description: String
    let date: String
    let isOutgoing: Bool
    let account: AccountDTO?
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountId = "account_id"
        case amount
        case type
        case category
        case description
        case date
        case isOutgoing = "is_outgoing"
        case account
    }
    
    /// 도메인 모델로 변환
    func toEntity() -> TransactionEntity {
        let dateFormatter = ISO8601DateFormatter()
        let parsedDate = dateFormatter.date(from: date) ?? Date()
        
        return TransactionEntity(
            id: id,
            amount: amount,
            type: mapTransactionType(type),
            description: description,
            category: mapTransactionCategory(category),
            date: parsedDate,
            isOutgoing: isOutgoing,
            account: account?.toEntity()
        )
    }
    
    /// 거래 타입 문자열을 TransactionType으로 매핑
    private func mapTransactionType(_ typeString: String) -> TransactionTypeEntity {
        switch typeString.uppercased() {
        case "DEPOSIT":
            return .deposit
        case "WITHDRAWAL":
            return .withdrawal
        case "TRANSFER":
            return .transfer
        case "PAYMENT":
            return .payment
        case "FEE":
            return .fee
        default:
            return isOutgoing ? .withdrawal : .deposit
        }
    }
    
    /// 거래 카테고리 문자열을 TransactionCategory로 매핑
    private func mapTransactionCategory(_ categoryString: String?) -> TransactionCategoryEntity {
        guard let categoryString = categoryString else {
            return .other
        }
        
        switch categoryString.uppercased() {
        case "FOOD":
            return .food
        case "TRANSPORTATION":
            return .transportation
        case "HOUSING":
            return .housing
        case "ENTERTAINMENT":
            return .entertainment
        case "SHOPPING":
            return .shopping
        case "UTILITIES":
            return .utilities
        case "HEALTH":
            return .health
        case "EDUCATION":
            return .education
        case "INCOME":
            return .income
        case "TRANSFER":
            return .transfer
        default:
            return .other
        }
    }
} 
