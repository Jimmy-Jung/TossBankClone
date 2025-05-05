import Foundation
import DomainModule

/// 계좌 확인 응답 DTO
public struct VerifyAccountResponseDTO: Decodable {
    public let isValid: Bool
    public let holderName: String?
    public let bankName: String?
}

/// 송금 응답 DTO
public struct TransferResponseDTO: Decodable {
    public let transactionId: String
    public let fromAccountId: String
    public let toAccountNumber: String
    public let amount: Decimal
    public let fee: Decimal?
    public let status: String
    public let timestamp: Date
    
    public func toEntity() -> TransferResultEntity {
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
public struct TransferHistoryDTO: Decodable {
    public let id: String
    public let fromAccountId: String
    public let toAccountNumber: String
    public let toAccountName: String?
    public let amount: Decimal
    public let description: String
    public let timestamp: Date
    public let status: String
    
    public func toEntity() -> TransferHistoryEntity {
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
public struct FrequentAccountDTO: Decodable {
    public let id: String
    public let bankName: String
    public let accountNumber: String
    public let holderName: String
    public let nickname: String?
    public let lastUsed: Date?
    
    public func toEntity() -> FrequentAccountEntity {
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
