import Foundation
import DomainModule
import Combine

/// 계좌 API 서비스
public protocol AccountAPIServiceProtocol {
    /// 사용자 계좌 목록 조회
    func fetchAccounts() -> AnyPublisher<[Account], NetworkError>
    
    /// 계좌 거래 내역 조회
    func fetchTransactions(accountId: String, page: Int, limit: Int) -> AnyPublisher<[Transaction], NetworkError>
    
    /// 계좌 상세 정보 조회
    func fetchAccountDetails(accountId: String) -> AnyPublisher<Account, NetworkError>
}

/// 계좌 API 서비스 구현체
public final class AccountAPIService: AccountAPIServiceProtocol {
    private let networkService: NetworkServiceProtocol
    
    /// 계좌 API 서비스 초기화
    /// - Parameter networkService: 네트워크 서비스
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    /// 사용자 계좌 목록 조회
    public func fetchAccounts() -> AnyPublisher<[Account], NetworkError> {
        let endpoint = Endpoint<[AccountDTO]>(
            path: "/api/v1/accounts"
        )
        
        return networkService.request(endpoint)
            .map { dtos in dtos.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }
    
    /// 계좌 거래 내역 조회
    public func fetchTransactions(accountId: String, page: Int, limit: Int) -> AnyPublisher<[Transaction], NetworkError> {
        let endpoint = Endpoint<[TransactionDTO]>(
            path: "/api/v1/accounts/\(accountId)/transactions",
            queryParameters: [
                "page": "\(page)",
                "limit": "\(limit)"
            ]
        )
        
        return networkService.request(endpoint)
            .map { dtos in dtos.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }
    
    /// 계좌 상세 정보 조회
    public func fetchAccountDetails(accountId: String) -> AnyPublisher<Account, NetworkError> {
        let endpoint = Endpoint<AccountDTO>(
            path: "/api/v1/accounts/\(accountId)"
        )
        
        return networkService.request(endpoint)
            .map { $0.toDomain() }
            .eraseToAnyPublisher()
    }
}

// MARK: - 사용 예제

/*
 // 네트워크 서비스 및 API 서비스 초기화
 let baseURL = URL(string: "https://api.tossbank.com")!
 let networkService = NetworkService(
     baseURL: baseURL,
     authTokenProvider: { UserDefaults.standard.string(forKey: "authToken") }
 )
 let accountService = AccountAPIService(networkService: networkService)
 
 // 계좌 목록 조회 사용 예제
 accountService.fetchAccounts()
     .receive(on: DispatchQueue.main)
     .sink(
         receiveCompletion: { completion in
             switch completion {
             case .finished:
                 break
             case .failure(let error):
                 print("계좌 목록 조회 실패: \(error)")
             }
         },
         receiveValue: { accounts in
             print("계좌 목록: \(accounts)")
         }
     )
     .store(in: &cancellables)
 
 // 계좌 거래 내역 조회 사용 예제
 accountService.fetchTransactions(accountId: "account123", page: 1, limit: 20)
     .receive(on: DispatchQueue.main)
     .sink(
         receiveCompletion: { completion in
             switch completion {
             case .finished:
                 break
             case .failure(let error):
                 print("거래 내역 조회 실패: \(error)")
             }
         },
         receiveValue: { transactions in
             print("거래 내역: \(transactions)")
         }
     )
     .store(in: &cancellables)
 */ 
