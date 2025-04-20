import Foundation
import DomainModule

/// 송금 응답 DTO
public struct TransferResponseDTO: Decodable {
    let transactionId: String
    let fromAccountId: String
    let toAccountNumber: String
    let amount: Decimal
    let fee: Decimal
    let status: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case fromAccountId = "from_account_id"
        case toAccountNumber = "to_account_number"
        case amount
        case fee
        case status
        case timestamp
    }
    
    /// 도메인 모델로 변환
    func toEntity() -> TransferResultEntity {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: timestamp) ?? Date()
        
        return TransferResultEntity(
            transactionId: transactionId,
            fromAccountId: fromAccountId,
            toAccountNumber: toAccountNumber,
            amount: amount,
            fee: fee,
            status: TransferStatusEntity(rawValue: status.uppercased()) ?? .completed,
            timestamp: date
        )
    }
}

/// 송금 내역 DTO
public struct TransferHistoryDTO: Decodable {
    let id: String
    let fromAccountId: String
    let toAccountId: String?
    let toAccountNumber: String
    let toAccountName: String?
    let amount: Decimal
    let description: String
    let status: String
    let timestamp: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case fromAccountId = "from_account_id"
        case toAccountId = "to_account_id"
        case toAccountNumber = "to_account_number"
        case toAccountName = "to_account_name"
        case amount
        case description
        case status
        case timestamp
    }
    
    /// 도메인 모델로 변환
    func toEntity() -> TransferHistoryEntity {
        let formatter = ISO8601DateFormatter()
        let date = formatter.date(from: timestamp) ?? Date()
        
        return TransferHistoryEntity(
            id: id,
            fromAccountId: fromAccountId,
            toAccountId: toAccountId,
            toAccountNumber: toAccountNumber,
            toAccountName: toAccountName,
            amount: amount,
            description: description,
            timestamp: date,
            status: TransferStatusEntity(rawValue: status.uppercased()) ?? .completed
        )
    }
}

/// 자주 쓰는 계좌 DTO
public struct FrequentAccountDTO: Decodable {
    let id: String
    let bankName: String
    let accountNumber: String
    let holderName: String
    let nickname: String?
    let lastUsed: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case bankName = "bank_name"
        case accountNumber = "account_number"
        case holderName = "holder_name"
        case nickname
        case lastUsed = "last_used"
    }
    
    /// 도메인 모델로 변환
    func toEntity() -> FrequentAccountEntity {
        var lastUsedDate: Date? = nil
        
        if let lastUsed = lastUsed {
            let formatter = ISO8601DateFormatter()
            lastUsedDate = formatter.date(from: lastUsed)
        }
        
        return FrequentAccountEntity(
            id: id,
            bankName: bankName,
            accountNumber: accountNumber,
            holderName: holderName,
            nickname: nickname,
            lastUsed: lastUsedDate
        )
    }
} 
