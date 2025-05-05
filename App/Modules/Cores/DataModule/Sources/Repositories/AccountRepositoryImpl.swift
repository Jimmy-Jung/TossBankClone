import Foundation
import DomainModule
import NetworkModule

// 인메모리 기반 Repository
public class AccountRepositoryImpl: AccountRepositoryProtocol {
    // 인메모리 저장소
    private var accounts: [AccountEntity] = []
    private let apiClient: APIClient?
    
    // MARK: - 생성자
    
    /// 오프라인 전용 리포지토리 초기화
    public init() {
        self.apiClient = nil
    }
    
    /// 네트워크 지원 리포지토리 초기화
    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - 계좌 조회 메서드
    
    public func fetchAccounts() async throws -> [AccountEntity] {
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = AccountListRequest()
                let accountDTOs = try await apiClient.send(request)
                
                // DTO를 도메인 엔티티로 변환
                let accountEntities = accountDTOs.map { $0.toEntity() }
                
                // 로컬 캐시 업데이트
                await updateLocalAccounts(with: accountEntities)
                
                return accountEntities
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 로컬 데이터 반환
                return accounts
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
        
        // API 클라이언트가 없는 경우 로컬 데이터 반환
        return accounts
    }
    
    public func fetchAccount(withId id: String) async throws -> AccountEntity? {
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = AccountDetailRequest(accountId: id)
                let accountDTO = try await apiClient.send(request)
                
                // DTO를 도메인 엔티티로 변환
                let accountEntity = accountDTO.toEntity()
                
                // 로컬 캐시 업데이트
                await updateLocalAccount(accountEntity)
                
                return accountEntity
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 로컬 데이터 반환
                return accounts.first { $0.id == id }
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
        
        // API 클라이언트가 없는 경우 로컬 데이터 반환
        return accounts.first { $0.id == id }
    }
    
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [TransactionEntity] {
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = TransactionListRequest(
                    accountId: accountId,
                    limit: limit,
                    offset: offset
                )
                let transactionDTOs = try await apiClient.send(request)
                
                // DTO를 도메인 엔티티로 변환
                let transactionEntities = transactionDTOs.map { $0.toEntity() }
                
                // 로컬 캐시 업데이트
                await updateLocalTransactions(forAccountId: accountId, transactions: transactionEntities)
                
                return transactionEntities
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 로컬 데이터 반환
                return await getLocalTransactions(forAccountId: accountId, limit: limit, offset: offset)
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
        
        // API 클라이언트가 없는 경우 로컬 데이터 반환
        return await getLocalTransactions(forAccountId: accountId, limit: limit, offset: offset)
    }
    
    // MARK: - 계좌 관리 메서드
    
    public func saveAccount(_ account: AccountEntity) async throws {
        // 로컬 캐시 업데이트
        await updateLocalAccount(account)
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let accountDTO = account.toDTO()
                let request = SaveAccountRequest(account: accountDTO)
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에만 저장)
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
    }
    
    public func deleteAccount(withId id: String) async throws {
        // 로컬 캐시에서 삭제
        accounts.removeAll { $0.id == id }
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = DeleteAccountRequest(accountId: id)
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에서만 삭제)
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
    }
    
    public func updateAccount(_ account: AccountEntity) async throws {
        // 로컬 캐시 업데이트
        await updateLocalAccount(account)
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let accountDTO = account.toDTO()
                let request = UpdateAccountRequest(account: accountDTO)
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에만 업데이트)
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
    }
    
    public func addTransaction(_ transaction: TransactionEntity, toAccountWithId accountId: String) async throws {
        var tempTransaction = transaction
        
        // 로컬 캐시 업데이트
        await addLocalTransaction(&tempTransaction, toAccountWithId: accountId)
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let transactionDTO = tempTransaction.toDTO()
                let request = AddTransactionRequest(accountId: accountId, transaction: transactionDTO)
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에만 추가)
            } catch {
                // 기타 오류는 상위로 전달
                throw error
            }
        }
    }
    
    // MARK: - 내부 헬퍼 메서드
    
    /// 로컬 거래내역 조회
    private func getLocalTransactions(forAccountId accountId: String, limit: Int, offset: Int) async -> [TransactionEntity] {
        guard let account = accounts.first(where: { $0.id == accountId }),
              let transactions = account.transactions else {
            return []
        }
        
        let sortedTransactions = transactions.sorted { $0.date > $1.date }
        
        // 페이지네이션 적용
        if offset < sortedTransactions.count {
            let endIndex = min(offset + limit, sortedTransactions.count)
            return Array(sortedTransactions[offset..<endIndex])
        }
        
        return []
    }
    
    /// 로컬 계좌 목록 업데이트
    private func updateLocalAccounts(with newAccounts: [AccountEntity]) async {
        for newAccount in newAccounts {
            if let index = accounts.firstIndex(where: { $0.id == newAccount.id }) {
                // 기존 계좌 업데이트
                accounts[index].name = newAccount.name
                accounts[index].type = newAccount.type
                accounts[index].number = newAccount.number
                accounts[index].balance = newAccount.balance
                accounts[index].isActive = newAccount.isActive
                accounts[index].updatedAt = Date()
            } else {
                // 새 계좌 추가
                accounts.append(newAccount)
            }
        }
    }
    
    /// 로컬 계좌 업데이트
    private func updateLocalAccount(_ account: AccountEntity) async {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            // 기존 계좌 업데이트
            accounts[index] = account
        } else {
            // 새 계좌 추가
            accounts.append(account)
        }
    }
    
    /// 로컬 거래내역 업데이트
    private func updateLocalTransactions(forAccountId accountId: String, transactions: [TransactionEntity]) async {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else {
            return
        }
        
        var account = accounts[accountIndex]
        
        // 기존 거래내역 ID 수집
        let existingTransactionIds = (account.transactions ?? []).map { $0.id }
        let existingIdSet = Set(existingTransactionIds)
        
        // 새 거래내역 추가
        for transaction in transactions {
            var tempTransaction = transaction
            if !existingIdSet.contains(transaction.id) {
                // 새 거래내역만 추가
                tempTransaction.account = account
                if account.transactions == nil {
                    account.transactions = []
                }
                account.transactions?.append(tempTransaction)
            }
        }
        
        accounts[accountIndex] = account
    }
    
    /// 로컬 거래내역 추가
    private func addLocalTransaction(_ transaction: inout TransactionEntity, toAccountWithId accountId: String) async {
        guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else {
            return
        }
        
        var account = accounts[accountIndex]
        
        if account.transactions == nil {
            account.transactions = []
        }
        
        transaction.account = account
        account.transactions?.append(transaction)
        
        // 잔액 업데이트
        switch transaction.type {
        case .deposit:
            account.balance += transaction.amount
        case .withdrawal:
            account.balance -= transaction.amount
        case .transfer:
            if transaction.isOutgoing {
                account.balance -= transaction.amount
            } else {
                account.balance += transaction.amount
            }
        case .payment:
            account.balance -= transaction.amount
        case .fee:
            account.balance -= transaction.amount
        case .unknown:
            break // 처리하지 않음
        }
        
        account.updatedAt = Date()
        accounts[accountIndex] = account
    }
}

// MARK: - DTO 변환 메서드
extension AccountEntity {
    func toDTO() -> AccountDTO {
        return AccountDTO(
            id: id,
            name: name,
            type: type.rawValue,
            number: number,
            balance: balance,
            isActive: isActive
        )
    }
}

extension TransactionEntity {
    func toDTO() -> TransactionDTO {
        return TransactionDTO(
            id: id,
            amount: amount,
            type: type.rawValue,
            date: date,
            description: description,
            isOutgoing: isOutgoing
        )
    }
}



