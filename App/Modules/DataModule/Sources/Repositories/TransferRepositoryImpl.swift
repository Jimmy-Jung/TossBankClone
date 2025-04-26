import Foundation
import DomainModule
import NetworkModule

public final class TransferRepositoryImpl: TransferRepositoryProtocol {
    // MARK: - 속성
    private var transferHistories: [TransferHistoryEntity] = []
    private var frequentAccounts: [FrequentAccountEntity] = []
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
    
    // MARK: - 송금 기능
    
    /// 송금 실행
    public func transfer(
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String
    ) async throws -> TransferResultEntity {
        // 송금은 온라인 상태에서만 가능
        guard let apiClient = apiClient else {
            throw TransferError.networkError
        }
        
        do {
            // API 요청 생성 및 전송
            let transferRequest = TransferRequest(
                fromAccountId: fromAccountId,
                toAccountNumber: toAccountNumber,
                amount: amount,
                description: description.isEmpty ? nil : description
            )
            
            let responseDTO = try await apiClient.send(transferRequest)
            let transferResult = responseDTO.toEntity()
            
            // 로컬 캐시에 송금 내역 저장
            await addLocalTransferHistory(
                id: transferResult.transactionId,
                fromAccountId: transferResult.fromAccountId,
                toAccountNumber: transferResult.toAccountNumber,
                amount: transferResult.amount,
                description: description,
                status: transferResult.status,
                timestamp: transferResult.timestamp
            )
            
            return transferResult
        } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
            throw TransferError.networkError
        } catch let error as NetworkError {
            throw convertNetworkErrorToTransferError(error)
        } catch {
            throw TransferError.unknown
        }
    }
    
    /// 송금 내역 조회
    public func fetchTransferHistory(accountId: String, limit: Int, offset: Int) async throws -> [TransferHistoryEntity] {
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = TransferHistoryRequest(
                    accountId: accountId,
                    limit: limit,
                    offset: offset
                )
                
                let responseDTOs = try await apiClient.send(request)
                let transferHistories = responseDTOs.map { $0.toEntity() }
                
                // 로컬 캐시 업데이트
                await updateLocalTransferHistory(transferHistories)
                
                return transferHistories
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 로컬 데이터 반환
                return await getLocalTransferHistory(accountId: accountId, limit: limit, offset: offset)
            } catch {
                // 기타 오류는 상위로 전달
                throw convertNetworkError(error)
            }
        }
        
        // API 클라이언트가 없는 경우 로컬 데이터 반환
        return await getLocalTransferHistory(accountId: accountId, limit: limit, offset: offset)
    }
    
    // MARK: - 자주 쓰는 계좌 관리
    
    /// 자주 쓰는 계좌 목록 조회
    public func fetchFrequentAccounts() async throws -> [FrequentAccountEntity] {
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = FrequentAccountsRequest()
                let responseDTOs = try await apiClient.send(request)
                let frequentAccounts = responseDTOs.map { $0.toEntity() }
                
                // 로컬 캐시 업데이트
                await updateLocalFrequentAccounts(frequentAccounts)
                
                return frequentAccounts
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 로컬 데이터 반환
                return frequentAccounts
            } catch {
                // 기타 오류는 상위로 전달
                throw convertNetworkError(error)
            }
        }
        
        // API 클라이언트가 없는 경우 로컬 데이터 반환
        return frequentAccounts
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
            nickname: nickname,
            lastUsed: Date()
        )
        
        // 로컬 캐시에 저장
        await addLocalFrequentAccount(account)
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = AddFrequentAccountRequest(
                    bankName: account.bankName,
                    accountNumber: account.accountNumber,
                    holderName: account.holderName,
                    nickname: account.nickname
                )
                
                let responseDTO = try await apiClient.send(request)
                let updatedAccount = responseDTO.toEntity()
                
                // 서버에서 받은 ID로 로컬 데이터 업데이트
                if account.id != updatedAccount.id {
                    await updateLocalFrequentAccountId(oldId: account.id, newId: updatedAccount.id)
                    return updatedAccount
                }
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에만 저장)
            } catch {
                // 기타 오류는 상위로 전달
                throw convertNetworkError(error)
            }
        }
        
        return account
    }
    
    /// 자주 쓰는 계좌 삭제
    public func deleteFrequentAccount(id: String) async throws {
        // 로컬 캐시에서 삭제
        await removeLocalFrequentAccount(id: id)
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = RemoveFrequentAccountRequest(id: id)
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에서만 삭제)
            } catch {
                // 기타 오류는 상위로 전달
                throw convertNetworkError(error)
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
        // 로컬 캐시에서 계좌 찾기
        guard let existingAccount = frequentAccounts.first(where: { $0.id == id }) else {
            throw RepositoryError.itemNotFound
        }
        
        // 새 계좌 객체 생성 (순수 함수 스타일)
        let updatedAccount = FrequentAccountEntity(
            id: id,
            bankName: bankName ?? existingAccount.bankName,
            accountNumber: accountNumber ?? existingAccount.accountNumber,
            holderName: holderName ?? existingAccount.holderName,
            nickname: nickname,
            lastUsed: Date()
        )
        
        // 배열에서 기존 계좌 교체
        if let index = frequentAccounts.firstIndex(where: { $0.id == id }) {
            frequentAccounts[index] = updatedAccount
        }
        
        // API 클라이언트 확인
        if let apiClient = apiClient {
            do {
                // API 요청 생성 및 전송
                let request = UpdateFrequentAccountRequest(
                    id: id,
                    bankName: bankName,
                    accountNumber: accountNumber,
                    holderName: holderName,
                    nickname: nickname
                )
                
                _ = try await apiClient.send(request)
            } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
                // 오프라인일 경우 무시 (로컬에만 업데이트)
            } catch {
                // 기타 오류는 상위로 전달
                throw convertNetworkError(error)
            }
        }
        
        return updatedAccount
    }
    
    /// 계좌 확인
    public func verifyAccount(accountNumber: String, bankCode: String?) async throws -> Bool {
        // 계좌 확인은 온라인 상태에서만 가능
        guard let apiClient = apiClient else {
            throw RepositoryError.offlineError
        }
        
        do {
            // API 요청 생성 및 전송
            let request = VerifyAccountRequest(
                accountNumber: accountNumber,
                bankCode: bankCode
            )
            
            let response = try await apiClient.send(request)
            return response.isValid
        } catch let error as NetworkError where error == .offline || error == .noInternetConnection {
            throw RepositoryError.offlineError
        } catch {
            throw convertNetworkError(error)
        }
    }
    
    // MARK: - 내부 헬퍼 메서드
    
    /// 로컬 송금 내역 조회
    private func getLocalTransferHistory(accountId: String, limit: Int, offset: Int) async -> [TransferHistoryEntity] {
        let filteredHistory = transferHistories.filter { $0.fromAccountId == accountId }
        let sortedHistory = filteredHistory.sorted { $0.timestamp > $1.timestamp }
        
        // 페이지네이션 적용
        if offset < sortedHistory.count {
            let endIndex = min(offset + limit, sortedHistory.count)
            return Array(sortedHistory[offset..<endIndex])
        }
        
        return []
    }
    
    /// 로컬 송금 내역 추가
    private func addLocalTransferHistory(
        id: String = UUID().uuidString,
        fromAccountId: String,
        toAccountNumber: String,
        amount: Decimal,
        description: String,
        status: TransferStatusEntity,
        timestamp: Date = Date()
    ) async {
        let transferHistory = TransferHistoryEntity(
            id: id,
            fromAccountId: fromAccountId,
            toAccountNumber: toAccountNumber,
            toAccountName: "Unknown", // API 응답에서 받을 수 있으면 업데이트
            amount: amount,
            description: description,
            timestamp: timestamp,
            status: status
        )
        
        transferHistories.append(transferHistory)
    }
    
    /// 로컬 송금 내역 업데이트
    private func updateLocalTransferHistory(_ histories: [TransferHistoryEntity]) async {
        for history in histories {
            if let index = transferHistories.firstIndex(where: { $0.id == history.id }) {
                // 기존 내역 업데이트
                transferHistories[index] = history
            } else {
                // 새 내역 추가
                transferHistories.append(history)
            }
        }
    }
    
    /// 로컬 자주 쓰는 계좌 추가
    private func addLocalFrequentAccount(_ account: FrequentAccountEntity) async {
        frequentAccounts.append(account)
    }
    
    /// 로컬 자주 쓰는 계좌 ID 업데이트
    private func updateLocalFrequentAccountId(oldId: String, newId: String) async {
        if let index = frequentAccounts.firstIndex(where: { $0.id == oldId }) {
            let existingAccount = frequentAccounts[index]
            
            // 새 ID로 새 객체 생성
            let updatedAccount = FrequentAccountEntity(
                id: newId,
                bankName: existingAccount.bankName,
                accountNumber: existingAccount.accountNumber,
                holderName: existingAccount.holderName,
                nickname: existingAccount.nickname,
                lastUsed: existingAccount.lastUsed
            )
            
            // 기존 객체를 새 객체로 교체
            frequentAccounts[index] = updatedAccount
        }
    }
    
    /// 로컬 자주 쓰는 계좌 목록 업데이트
    private func updateLocalFrequentAccounts(_ accounts: [FrequentAccountEntity]) async {
        // 서버에 없는 계좌 삭제
        let onlineIds = Set(accounts.map { $0.id })
        frequentAccounts.removeAll { !onlineIds.contains($0.id) }
        
        // 계좌 정보 업데이트 또는 추가
        for account in accounts {
            if let index = frequentAccounts.firstIndex(where: { $0.id == account.id }) {
                // 기존 계좌 업데이트
                frequentAccounts[index] = account
            } else {
                // 새 계좌 추가
                frequentAccounts.append(account)
            }
        }
    }
    
    /// 로컬 자주 쓰는 계좌 삭제
    private func removeLocalFrequentAccount(id: String) async {
        frequentAccounts.removeAll { $0.id == id }
    }
    
    /// 네트워크 오류를 송금 오류로 변환
    private func convertNetworkErrorToTransferError(_ error: NetworkError) -> TransferError {
        switch error {
        case .offline, .noInternetConnection:
            return TransferError.networkError
        case .httpError(let statusCode, _), .serverError(let statusCode, _):
            switch statusCode {
            case 400: return TransferError.invalidAccount
            case 402: return TransferError.insufficientFunds
            case 403: return TransferError.transferLimitExceeded
            case 404: return TransferError.accountNotFound
            case 500...599: return TransferError.serverError
            default: return TransferError.unknown
            }
        case .unauthorized:
            return TransferError.unauthorized
        default:
            return TransferError.unknown
        }
    }
    
    /// 네트워크 오류 변환
    private func convertNetworkError(_ error: Error) -> Error {
        if let networkError = error as? NetworkError {
            switch networkError {
            case .unauthorized:
                return RepositoryError.unauthorized
            case .httpError(let statusCode, _), .serverError(let statusCode, _):
                if statusCode == 404 {
                    return RepositoryError.itemNotFound
                }
                return RepositoryError.serverError
            case .offline, .noInternetConnection:
                return RepositoryError.offlineError
            default:
                return RepositoryError.networkError
            }
        }
        return error
    }
}
