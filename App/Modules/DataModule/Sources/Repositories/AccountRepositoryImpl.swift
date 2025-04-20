import Foundation
import DomainModule
import NetworkModule

// 인메모리 기반 Repository
public class AccountRepositoryImpl: AccountRepositoryProtocol {
    // 인메모리 저장소
    private var accounts: [AccountEntity] = []
    private let onlineRepository: OnlineAccountRepository?
    private let connectivityChecker: NetworkReachability
    
    public init() {
        self.onlineRepository = nil
        self.connectivityChecker = NetworkReachabilityImpl.shared
    }
    
    public init(apiClient: APIClient, connectivityChecker: NetworkReachability = NetworkReachabilityImpl.shared) {
        self.onlineRepository = OnlineAccountRepository(apiClient: apiClient)
        self.connectivityChecker = connectivityChecker
    }
    
    public func fetchAccounts() async throws -> [AccountEntity] {
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에서 최신 데이터 가져오기
        if connectivityChecker.isConnected && onlineRepository != nil {
            do {
                let onlineAccounts = try await onlineRepository!.fetchAccounts()
                
                // 온라인 데이터로 로컬 데이터 업데이트
                await updateLocalAccounts(with: onlineAccounts)
                
                return onlineAccounts
            } catch {
                // API 요청 실패 시 로컬 데이터 조회
                print("온라인 계좌 조회 실패: \(error.localizedDescription)")
            }
        }
        
        // 오프라인이거나 온라인 요청 실패 시 로컬 데이터 반환
        return await withCheckedContinuation { continuation in
            continuation.resume(returning: accounts)
        }
    }
    
    public func fetchAccount(withId id: String) async throws -> AccountEntity? {
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에서 최신 데이터 가져오기
        if connectivityChecker.isConnected && onlineRepository != nil {
            do {
                let onlineAccount = try await onlineRepository!.fetchAccount(id: id)
                
                // 온라인 데이터로 로컬 데이터 업데이트
                await updateLocalAccount(onlineAccount)
                
                return onlineAccount
            } catch {
                // API 요청 실패 시 로컬 데이터 조회
                print("온라인 계좌 상세 조회 실패: \(error.localizedDescription)")
            }
        }
        
        // 오프라인이거나 온라인 요청 실패 시 로컬 데이터 반환
        return await withCheckedContinuation { continuation in
            let account = accounts.first { $0.id == id }
            continuation.resume(returning: account)
        }
    }
    
    public func fetchTransactions(forAccountId accountId: String, limit: Int, offset: Int) async throws -> [TransactionEntity] {
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에서 최신 데이터 가져오기
        if connectivityChecker.isConnected && onlineRepository != nil {
            do {
                let onlineTransactions = try await onlineRepository!.fetchTransactions(
                    forAccountId: accountId, 
                    limit: limit, 
                    offset: offset
                )
                
                // 온라인 데이터로 로컬 데이터 업데이트
                await updateLocalTransactions(forAccountId: accountId, transactions: onlineTransactions)
                
                return onlineTransactions
            } catch {
                // API 요청 실패 시 로컬 데이터 조회
                print("온라인 거래내역 조회 실패: \(error.localizedDescription)")
            }
        }
        
        // 오프라인이거나 온라인 요청 실패 시 로컬 데이터 반환
        return await withCheckedContinuation { continuation in
            guard let account = accounts.first(where: { $0.id == accountId }),
                  let transactions = account.transactions else {
                continuation.resume(returning: [])
                return
            }
            
            let sortedTransactions = transactions.sorted { $0.date > $1.date }
            let paginatedTransactions: [TransactionEntity]
            
            if offset < sortedTransactions.count {
                let endIndex = min(offset + limit, sortedTransactions.count)
                paginatedTransactions = Array(sortedTransactions[offset..<endIndex])
            } else {
                paginatedTransactions = []
            }
            
            continuation.resume(returning: paginatedTransactions)
        }
    }
    
    public func saveAccount(_ account: AccountEntity) async throws {
        // 로컬 데이터베이스에 저장
        await withCheckedContinuation { continuation in
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index] = account
            } else {
                accounts.append(account)
            }
            continuation.resume(returning: ())
        }
        
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에도 저장 (향후 구현)
    }
    
    public func deleteAccount(withId id: String) async throws {
        // 로컬 데이터베이스에서 삭제
        await withCheckedContinuation { continuation in
            accounts.removeAll { $0.id == id }
            continuation.resume(returning: ())
        }
        
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에도 삭제 요청 (향후 구현)
    }
    
    public func updateAccount(_ account: AccountEntity) async throws {
        // 로컬 데이터베이스 업데이트
        await withCheckedContinuation { continuation in
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                accounts[index] = account
            }
            continuation.resume(returning: ())
        }
        
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에도 업데이트 요청 (향후 구현)
    }
    
    public func addTransaction(_ transaction: TransactionEntity, toAccountWithId accountId: String) async throws {
        var tempTransaction = transaction
        // 로컬 데이터베이스에 거래내역 추가
        await withCheckedContinuation { continuation in
            guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else {
                // continuation.resume(throwing: RepositoryError.itemNotFound)
                return
            }
            
            var account = accounts[accountIndex]
            
            if account.transactions == nil {
                account.transactions = []
            }
            
            tempTransaction.account = account
            account.transactions?.append(tempTransaction)
            
            // 잔액 업데이트
            switch transaction.type {
            case .deposit:
                account.balance += tempTransaction.amount
            case .withdrawal:
                account.balance -= tempTransaction.amount
            case .transfer:
                if tempTransaction.isOutgoing {
                    account.balance -= tempTransaction.amount
                } else { // outgoing 또는 reference가 nil인 경우 포함
                    account.balance += tempTransaction.amount
                }
            case .payment:
                account.balance -= tempTransaction.amount
            case .fee:
                account.balance -= tempTransaction.amount
            }
            
            account.updatedAt = Date()
            
            accounts[accountIndex] = account
            continuation.resume(returning: ())
        }
        
        // 온라인 상태이고 온라인 리포지토리가 있으면 API에도 거래내역 추가 요청 (향후 구현)
    }
    
    public func generateMockData() {
        MockDataGenerator.generateMockData(into: &accounts)
    }
    
    // MARK: - Private 데이터 동기화 메서드
    
    private func updateLocalAccounts(with newAccounts: [AccountEntity]) async {
        await withCheckedContinuation { continuation in
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
            continuation.resume(returning: ())
        }
    }
    
    private func updateLocalAccount(_ account: AccountEntity) async {
        await withCheckedContinuation { continuation in
            if let index = accounts.firstIndex(where: { $0.id == account.id }) {
                // 기존 계좌 업데이트
                accounts[index].name = account.name
                accounts[index].type = account.type
                accounts[index].number = account.number
                accounts[index].balance = account.balance
                accounts[index].isActive = account.isActive
                accounts[index].updatedAt = Date()
            } else {
                // 새 계좌 추가
                accounts.append(account)
            }
            continuation.resume(returning: ())
        }
    }
    
    private func updateLocalTransactions(forAccountId accountId: String, transactions: [TransactionEntity]) async {
        await withCheckedContinuation { continuation in
            guard let accountIndex = accounts.firstIndex(where: { $0.id == accountId }) else {
                print("계좌를 찾을 수 없음: \(accountId)")
                continuation.resume(returning: ())
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
            continuation.resume(returning: ())
        }
    }
} 
