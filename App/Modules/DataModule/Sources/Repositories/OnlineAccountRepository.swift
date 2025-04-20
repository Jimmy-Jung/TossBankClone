import Foundation
import DomainModule
import NetworkModule

/// 온라인 계좌 리포지토리 오류
public enum OnlineRepositoryError: Error {
    case networkError
    case dataNotAvailable
    case conversionFailed
}

/// 온라인 계좌 리포지토리
public final class OnlineAccountRepository {
    // MARK: - 속성
    private let apiClient: APIClient
    private let networkQueue = DispatchQueue(label: "com.tossbankclone.network", qos: .userInitiated)
    
    // MARK: - 생성자
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - 공개 메서드
    
    /// 모든 계좌 조회
    /// - Returns: 계좌 목록
    public func fetchAccounts() async throws -> [AccountEntity] {
        do {
            let request = GetAccountsRequest()
            let accountDTOs = try await apiClient.send(request)
            return accountDTOs.map { $0.toEntity() }
        } catch {
            throw OnlineRepositoryError.networkError
        }
    }
    
    /// 단일 계좌 조회
    /// - Parameter accountId: 계좌 ID
    /// - Returns: 계좌 정보
    public func fetchAccount(id accountId: String) async throws -> AccountEntity {
        do {
            let request = GetAccountRequest(accountId: accountId)
            let accountDTO = try await apiClient.send(request)
            return accountDTO.toEntity()
        } catch {
            throw OnlineRepositoryError.networkError
        }
    }
    
    /// 계좌 거래내역 조회
    /// - Parameters:
    ///   - accountId: 계좌 ID
    ///   - limit: 조회할 최대 내역 수
    ///   - offset: 조회 시작 위치
    /// - Returns: 거래내역 목록
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [TransactionEntity] {
        do {
            let request = GetTransactionsRequest(accountId: accountId, limit: limit, offset: offset)
            let transactionDTOs = try await apiClient.send(request)
            return transactionDTOs.map { $0.toEntity() }
        } catch {
            throw OnlineRepositoryError.networkError
        }
    }
    
    /// 계좌 잔액 업데이트
    /// - Parameters:
    ///   - accountId: 계좌 ID
    ///   - newBalance: 새로운 잔액
    /// - Returns: 업데이트된 계좌 정보
    public func updateAccountBalance(id accountId: String, newBalance: Decimal) async throws -> AccountEntity {
        do {
            let request = UpdateAccountBalanceRequest(accountId: accountId, newBalance: newBalance)
            let accountDTO = try await apiClient.send(request)
            return accountDTO.toEntity()
        } catch {
            throw OnlineRepositoryError.networkError
        }
    }
} 
