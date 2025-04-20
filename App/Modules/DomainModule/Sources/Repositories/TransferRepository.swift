import Foundation

// MARK: - TransferRepository 프로토콜
public protocol TransferRepositoryProtocol {
    /// 송금 실행
    func transfer(
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String
    ) async throws -> TransferResultEntity
    
    /// 송금 내역 조회
    func fetchTransferHistory(accountId: String, limit: Int, offset: Int) async throws -> [TransferHistoryEntity]
    
    /// 자주 쓰는 계좌 목록 조회
    func fetchFrequentAccounts() async throws -> [FrequentAccountEntity]
    
    /// 자주 쓰는 계좌 추가
    func addFrequentAccount(
        bankName: String, 
        accountNumber: String, 
        holderName: String, 
        nickname: String?
    ) async throws -> FrequentAccountEntity
    
    /// 자주 쓰는 계좌 삭제
    func deleteFrequentAccount(id: String) async throws
    
    /// 자주 쓰는 계좌 업데이트
    func updateFrequentAccount(
        id: String,
        bankName: String?,
        accountNumber: String?,
        holderName: String?,
        nickname: String?
    ) async throws -> FrequentAccountEntity
    
    /// 단일 계좌 조회 (송금 대상 확인용)
    func verifyAccount(accountNumber: String, bankCode: String?) async throws -> Bool
}

// MARK: - 송금 관련 오류
public enum TransferError: Error {
    case insufficientFunds
    case invalidAccount
    case transferLimitExceeded
    case dailyLimitExceeded
    case networkError
    case unknown
} 