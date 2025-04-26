import Foundation
import DomainModule

/// 계좌 확인 응답 DTO
struct VerifyAccountResponseDTO: Decodable {
    let isValid: Bool
    let holderName: String?
    let bankName: String?
}

/// 송금 응답 DTO
struct TransferResponseDTO: Decodable {
    let transactionId: String
    let fromAccountId: String
    let toAccountNumber: String
    let amount: Decimal
    let fee: Decimal?
    let status: String
    let timestamp: Date
    
    func toEntity() -> TransferResultEntity {
        return TransferResultEntity(
            transactionId: transactionId,
            fromAccountId: fromAccountId,
            toAccountNumber: toAccountNumber,
            amount: amount,
            fee: fee,
            status: TransferStatusEntity(rawValue: status) ?? .completed,
            timestamp: timestamp
        )
    }
}

/// 송금 내역 DTO
struct TransferHistoryDTO: Decodable {
    let id: String
    let fromAccountId: String
    let toAccountNumber: String
    let toAccountName: String?
    let amount: Decimal
    let description: String
    let timestamp: Date
    let status: String
    
    func toEntity() -> TransferHistoryEntity {
        return TransferHistoryEntity(
            id: id,
            fromAccountId: fromAccountId,
            toAccountNumber: toAccountNumber,
            toAccountName: toAccountName ?? "Unknown",
            amount: amount,
            description: description,
            timestamp: timestamp,
            status: TransferStatusEntity(rawValue: status) ?? .completed
        )
    }
}

/// 자주 쓰는 계좌 DTO
struct FrequentAccountDTO: Decodable {
    let id: String
    let bankName: String
    let accountNumber: String
    let holderName: String
    let nickname: String?
    let lastUsed: Date?
    
    func toEntity() -> FrequentAccountEntity {
        return FrequentAccountEntity(
            id: id,
            bankName: bankName,
            accountNumber: accountNumber,
            holderName: holderName,
            nickname: nickname,
            lastUsed: lastUsed
        )
    }
}
