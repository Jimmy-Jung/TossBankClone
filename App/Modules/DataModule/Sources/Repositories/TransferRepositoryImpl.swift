import Foundation
import DomainModule
import NetworkModule

// 인메모리 저장소용 엔티티 클래스
public final class TransferEntity {
    public var id: String
    public var fromAccountId: String
    public var toAccountNumber: String
    public var toAccountName: String?
    public var amount: Decimal
    public var fee: Decimal?
    public var description: String?
    public var status: String
    public var timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        fromAccountId: String,
        toAccountNumber: String,
        toAccountName: String? = nil,
        amount: Decimal,
        fee: Decimal? = nil,
        description: String? = nil,
        status: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.fromAccountId = fromAccountId
        self.toAccountNumber = toAccountNumber
        self.toAccountName = toAccountName
        self.amount = amount
        self.fee = fee
        self.description = description
        self.status = status
        self.timestamp = timestamp
    }
    
    public func toTransferHistory() -> TransferHistoryEntity {
        return TransferHistoryEntity(
            id: id,
            fromAccountId: fromAccountId,
            toAccountNumber: toAccountNumber,
            toAccountName: toAccountName ?? "Unknown",
            amount: amount,
            description: description ?? "",
            timestamp: timestamp,
            status: TransferStatusEntity(rawValue: status) ?? .completed
        )
    }
}

// 인메모리 저장소용 자주 쓰는 계좌 엔티티 클래스
public final class FrequentAccountData {
    public var id: String
    public var bankName: String
    public var accountNumber: String
    public var holderName: String
    public var nickname: String?
    public var lastUsed: Date?
    
    public init(
        id: String = UUID().uuidString,
        bankName: String,
        accountNumber: String,
        holderName: String,
        nickname: String? = nil,
        lastUsed: Date? = nil
    ) {
        self.id = id
        self.bankName = bankName
        self.accountNumber = accountNumber
        self.holderName = holderName
        self.nickname = nickname
        self.lastUsed = lastUsed
    }
    
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
    
    public func toFrequentAccountEntity() -> FrequentAccountEntity {
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

public final class TransferRepositoryImpl: TransferRepositoryProtocol {
    // MARK: - 속성
    private var transferEntities: [TransferEntity] = []
    private var frequentAccounts: [FrequentAccountData] = []
    private let apiClient: APIClient?
    private let connectivityChecker: NetworkReachability
    
    // MARK: - 생성자
    public init() {
        self.apiClient = nil
        self.connectivityChecker = NetworkReachabilityImpl.shared
    }
    
    public init(apiClient: APIClient, connectivityChecker: NetworkReachability = NetworkReachabilityImpl.shared) {
        self.apiClient = apiClient
        self.connectivityChecker = connectivityChecker
    }
    
    // MARK: - TransferRepositoryProtocol 구현
    
    /// 송금 실행
    public func transfer(
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String
    ) async throws -> TransferResultEntity {
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 송금 시도
        if connectivityChecker.isConnected && apiClient != nil {
            do {
                let transferRequest = TransferRequest(
                    fromAccountId: fromAccountId,
                    toAccountNumber: toAccountNumber,
                    amount: amount,
                    description: description.isEmpty ? nil : description
                )
                
                let responseDTO = try await apiClient!.send(transferRequest)
                let transferResult = responseDTO.toEntity()
                
                // 로컬 데이터베이스에 송금 내역 저장
                await saveTransferToLocalDB(transferResult, description: description)
                
                // TransferResult를 TransferResultEntity로 변환
                return TransferResultEntity(
                    transactionId: transferResult.transactionId,
                    fromAccountId: transferResult.fromAccountId,
                    toAccountNumber: transferResult.toAccountNumber,
                    amount: transferResult.amount,
                    fee: transferResult.fee,
                    status: TransferStatusEntity(rawValue: transferResult.status.rawValue) ?? .completed,
                    timestamp: transferResult.timestamp
                )
            } catch let error as NetworkError {
                switch error {
                case .httpError(let statusCode, _):
                    switch statusCode {
                    case 400: throw TransferError.invalidAccount
                    case 402: throw TransferError.insufficientFunds
                    case 403: throw TransferError.transferLimitExceeded
                    default: throw TransferError.networkError
                    }
                case .offline, .noInternetConnection:
                    throw TransferError.networkError
                default:
                    throw TransferError.networkError
                }
            } catch {
                throw TransferError.unknown
            }
        } else {
            // 오프라인 모드: 오프라인 송금 불가, 에러 반환
            throw TransferError.networkError
        }
    }
    
    /// 송금 내역 조회
    public func fetchTransferHistory(accountId: String, limit: Int, offset: Int) async throws -> [TransferHistoryEntity] {
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 조회 시도
        if connectivityChecker.isConnected && apiClient != nil {
            do {
                let request = TransferHistoryRequest(
                    accountId: accountId,
                    limit: limit,
                    offset: offset
                )
                
                let responseDTOs = try await apiClient!.send(request)
                let transferHistories = responseDTOs.map { $0.toEntity() }
                
                // 로컬 데이터베이스 업데이트
                await updateLocalTransferHistory(transferHistories)
                
                // TransferHistory를 TransferHistoryEntity로 변환
                return transferHistories.map { history in
                    return TransferHistoryEntity(
                        id: history.id,
                        fromAccountId: history.fromAccountId,
                        toAccountNumber: history.toAccountNumber,
                        toAccountName: history.toAccountName ?? "Unknown",
                        amount: history.amount,
                        description: history.description,
                        timestamp: history.timestamp,
                        status: TransferStatusEntity(rawValue: history.status.rawValue) ?? .completed
                    )
                }
            } catch {
                // 온라인 조회 실패 시 로컬 데이터 반환
                let localHistories = try await fetchLocalTransferHistory(accountId: accountId, limit: limit, offset: offset)
                return localHistories.map { history in
                    return TransferHistoryEntity(
                        id: history.id,
                        fromAccountId: history.fromAccountId,
                        toAccountNumber: history.toAccountNumber,
                        toAccountName: history.toAccountName ?? "Unknown",
                        amount: history.amount,
                        description: history.description,
                        timestamp: history.timestamp,
                        status: TransferStatusEntity(rawValue: history.status.rawValue) ?? .completed
                    )
                }
            }
        } else {
            // 오프라인 모드: 로컬 데이터 반환
            let localHistories = try await fetchLocalTransferHistory(accountId: accountId, limit: limit, offset: offset)
            return localHistories.map { history in
                return TransferHistoryEntity(
                    id: history.id,
                    fromAccountId: history.fromAccountId,
                    toAccountNumber: history.toAccountNumber,
                    toAccountName: history.toAccountName ?? "Unknown",
                    amount: history.amount,
                    description: history.description,
                    timestamp: history.timestamp,
                    status: TransferStatusEntity(rawValue: history.status.rawValue) ?? .completed
                )
            }
        }
    }
    
    /// 자주 쓰는 계좌 목록 조회
    public func fetchFrequentAccounts() async throws -> [FrequentAccountEntity] {
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 조회 시도
        if connectivityChecker.isConnected && apiClient != nil {
            do {
                let request = FrequentAccountsRequest()
                let responseDTOs = try await apiClient!.send(request)
                let frequentAccounts = responseDTOs.map { $0.toEntity() }
                
                // 로컬 데이터베이스 업데이트
                await updateLocalFrequentAccounts(frequentAccounts)
                
                // FrequentAccount를 FrequentAccountEntity로 변환
                return frequentAccounts.map { account in
                    return FrequentAccountEntity(
                        id: account.id,
                        bankName: account.bankName,
                        accountNumber: account.accountNumber,
                        holderName: account.holderName,
                        nickname: account.nickname,
                        lastUsed: account.lastUsed
                    )
                }
            } catch {
                // 온라인 조회 실패 시 로컬 데이터 반환
                let localAccounts = try await fetchLocalFrequentAccounts()
                return localAccounts.map { account in
                    return FrequentAccountEntity(
                        id: account.id,
                        bankName: account.bankName,
                        accountNumber: account.accountNumber,
                        holderName: account.holderName,
                        nickname: account.nickname,
                        lastUsed: account.lastUsed
                    )
                }
            }
        } else {
            // 오프라인 모드: 로컬 데이터 반환
            let localAccounts = try await fetchLocalFrequentAccounts()
            return localAccounts.map { account in
                return FrequentAccountEntity(
                    id: account.id,
                    bankName: account.bankName,
                    accountNumber: account.accountNumber,
                    holderName: account.holderName,
                    nickname: account.nickname,
                    lastUsed: account.lastUsed
                )
            }
        }
    }
    
    /// 자주 쓰는 계좌 추가
    public func addFrequentAccount(
        bankName: String, 
        accountNumber: String, 
        holderName: String, 
        nickname: String?
    ) async throws -> FrequentAccountEntity {
        let account = FrequentAccountEntity(
            bankName: bankName,
            accountNumber: accountNumber,
            holderName: holderName,
            nickname: nickname
        )
        
        // 로컬 데이터베이스에 저장
        let entity = await addLocalFrequentAccount(account)
        
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 저장 시도
        if connectivityChecker.isConnected && apiClient != nil {
            do {
                let request = AddFrequentAccountRequest(
                    bankName: account.bankName,
                    accountNumber: account.accountNumber,
                    holderName: account.holderName,
                    nickname: account.nickname
                )
                
                _ = try await apiClient!.send(request)
            } catch {
                // 온라인 저장 실패 시 무시 (로컬에는 이미 저장됨)
                print("자주 쓰는 계좌 온라인 저장 실패: \(error.localizedDescription)")
            }
        }
        
        return entity.toFrequentAccountEntity()
    }
    
    /// 자주 쓰는 계좌 삭제
    public func deleteFrequentAccount(id: String) async throws {
        // 로컬 데이터베이스에서 삭제
        await withCheckedContinuation { continuation in
            frequentAccounts.removeAll { $0.id == id }
            continuation.resume(returning: ())
        }
        
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 삭제 시도
        if connectivityChecker.isConnected && apiClient != nil {
            do {
                let request = RemoveFrequentAccountRequest(id: id)
                _ = try await apiClient!.send(request)
            } catch {
                // 온라인 삭제 실패 시 무시 (로컬에서는 이미 삭제됨)
                print("자주 쓰는 계좌 온라인 삭제 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 자주 쓰는 계좌 업데이트
    public func updateFrequentAccount(
        id: String,
        bankName: String?,
        accountNumber: String?,
        holderName: String?,
        nickname: String?
    ) async throws -> FrequentAccountEntity {
        // 로컬 데이터베이스에서 계좌 찾기
        var updatedEntity: FrequentAccountData?
        
        await withCheckedContinuation { continuation in
            if let index = frequentAccounts.firstIndex(where: { $0.id == id }) {
                if let bankName = bankName {
                    frequentAccounts[index].bankName = bankName
                }
                if let accountNumber = accountNumber {
                    frequentAccounts[index].accountNumber = accountNumber
                }
                if let holderName = holderName {
                    frequentAccounts[index].holderName = holderName
                }
                frequentAccounts[index].nickname = nickname
                frequentAccounts[index].lastUsed = Date()
                
                updatedEntity = frequentAccounts[index]
            }
            continuation.resume(returning: ())
        }
        
        guard let entity = updatedEntity else {
            throw RepositoryError.itemNotFound
        }
        
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 업데이트 시도
        if connectivityChecker.isConnected && apiClient != nil {
            // TODO: API 요청 구현
        }
        
        return entity.toFrequentAccountEntity()
    }
    
    /// 계좌 확인
    public func verifyAccount(accountNumber: String, bankCode: String?) async throws -> Bool {
        // 온라인 상태이고 API 클라이언트가 있는 경우 온라인 확인 시도
        if connectivityChecker.isConnected && apiClient != nil {
            // TODO: API 요청 구현
            return true
        }
        
        // 오프라인 모드에서는 로컬 데이터에서 확인
        return await withCheckedContinuation { continuation in
            let exists = frequentAccounts.contains { $0.accountNumber == accountNumber }
            continuation.resume(returning: exists)
        }
    }
    
    // MARK: - 내부 헬퍼 메서드
    
    /// 로컬 데이터베이스에 송금 내역 저장
    private func saveTransferToLocalDB(_ transfer: TransferResultEntity, description: String) async {
        let entity = TransferEntity(
            id: transfer.transactionId,
            fromAccountId: transfer.fromAccountId,
            toAccountNumber: transfer.toAccountNumber,
            amount: transfer.amount,
            fee: transfer.fee,
            description: description,
            status: transfer.status.rawValue,
            timestamp: transfer.timestamp
        )
        
        transferEntities.append(entity)
    }
    
    /// 로컬 데이터베이스에서 송금 내역 조회
    private func fetchLocalTransferHistory(accountId: String, limit: Int, offset: Int) async throws -> [TransferHistoryEntity] {
        return await withCheckedContinuation { continuation in
            let filteredEntities = transferEntities.filter { $0.fromAccountId == accountId }
            let sortedEntities = filteredEntities.sorted { $0.timestamp > $1.timestamp }
            
            let paginatedEntities: [TransferEntity]
            if offset < sortedEntities.count {
                let endIndex = min(offset + limit, sortedEntities.count)
                paginatedEntities = Array(sortedEntities[offset..<endIndex])
            } else {
                paginatedEntities = []
            }
            
            let histories = paginatedEntities.map { $0.toTransferHistory() }
            continuation.resume(returning: histories)
        }
    }
    
    /// 로컬 데이터베이스 송금 내역 업데이트
    private func updateLocalTransferHistory(_ histories: [TransferHistoryEntity]) async {
        for history in histories {
            // 이미 존재하는지 확인
            if let index = transferEntities.firstIndex(where: { $0.id == history.id }) {
                // 기존 항목 업데이트
                transferEntities[index].status = history.status.rawValue
            } else {
                // 새 항목 추가
                let entity = TransferEntity(
                    id: history.id,
                    fromAccountId: history.fromAccountId,
                    toAccountNumber: history.toAccountNumber,
                    toAccountName: history.toAccountName,
                    amount: history.amount,
                    description: history.description,
                    status: history.status.rawValue,
                    timestamp: history.timestamp
                )
                
                transferEntities.append(entity)
            }
        }
    }
    
    /// 로컬 데이터베이스에서 자주 쓰는 계좌 조회
    private func fetchLocalFrequentAccounts() async throws -> [FrequentAccountEntity] {
        return await withCheckedContinuation { continuation in
            let sortedAccounts = frequentAccounts.sorted { 
                if let date1 = $0.lastUsed, let date2 = $1.lastUsed {
                    return date1 > date2
                }
                return ($0.lastUsed != nil) && ($1.lastUsed == nil)
            }
            
            let accounts = sortedAccounts.map { $0.toEntity() }
            continuation.resume(returning: accounts)
        }
    }
    
    /// 로컬 데이터베이스에 자주 쓰는 계좌 추가
    private func addLocalFrequentAccount(_ account: FrequentAccountEntity) async -> FrequentAccountData {
        return await withCheckedContinuation { continuation in
            let entity = FrequentAccountData(
                id: account.id,
                bankName: account.bankName,
                accountNumber: account.accountNumber,
                holderName: account.holderName,
                nickname: account.nickname,
                lastUsed: account.lastUsed ?? Date()
            )
            
            frequentAccounts.append(entity)
            continuation.resume(returning: entity)
        }
    }
    
    /// 로컬 데이터베이스 자주 쓰는 계좌 업데이트
    private func updateLocalFrequentAccounts(_ accounts: [FrequentAccountEntity]) async {
        // 서버에 없는 계좌 삭제
        let onlineIds = Set(accounts.map { $0.id })
        frequentAccounts.removeAll { !onlineIds.contains($0.id) }
        
        // 계좌 정보 업데이트 또는 추가
        for account in accounts {
            if let index = frequentAccounts.firstIndex(where: { $0.id == account.id }) {
                // 기존 계좌 업데이트
                frequentAccounts[index].bankName = account.bankName
                frequentAccounts[index].accountNumber = account.accountNumber
                frequentAccounts[index].holderName = account.holderName
                frequentAccounts[index].nickname = account.nickname
                frequentAccounts[index].lastUsed = account.lastUsed
            } else {
                // 새 계좌 추가
                let entity = FrequentAccountData(
                    id: account.id,
                    bankName: account.bankName,
                    accountNumber: account.accountNumber,
                    holderName: account.holderName,
                    nickname: account.nickname,
                    lastUsed: account.lastUsed
                )
                
                frequentAccounts.append(entity)
            }
        }
    }
} 
