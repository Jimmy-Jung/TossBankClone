//
//  AccountDIContainer.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import DataModule
import DomainModule
import NetworkModule
import SharedModule

/// 계좌 모듈 DI 컨테이너
public final class AccountDIContainer: AccountDIContainerProtocol {
    // MARK: - 속성
    private let environment: AppEnvironment
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL
    
    // MARK: - 초기화
    public init(
        environment: AppEnvironment,
        networkService: NetworkServiceProtocol,
        baseURL: URL
    ) {
        self.environment = environment
        self.networkService = networkService
        self.baseURL = baseURL
        
        if environment == .test {
            setupMockData()
        }
    }

    private func createAPIClient() -> APIClient {
        return NetworkAPIClient(networkService: networkService, baseURL: baseURL)
    }
    
    private func createAccountRepository() -> AccountRepositoryProtocol {
        return AccountRepositoryImpl(apiClient: createAPIClient())
    }
    
    public func makeAccountListViewModel() -> any AsyncViewModel {
        return AccountListViewModel(
            fetchAccountsUseCase: FetchAccountsUseCase(
                accountRepository: createAccountRepository()
            )
        )
    }
    
    public func makeAccountDetailViewModel(accountId: String) -> any AsyncViewModel {
        let accountRepository = createAccountRepository()
        
        return AccountDetailViewModel(
            accountId: accountId,
            fetchAccountDetailUseCase: FetchAccountDetailUseCase(
                accountRepository: accountRepository
            ),
            fetchTransactionsUseCase: FetchTransactionsUseCase(
                accountRepository: accountRepository
            )
        )
    }
    
    // 테스트 데이터 설정 메서드
    private func setupDefaultTestData() {
        // 기본 성공 응답 설정 예시
        let mockNetworkService = networkService as? MockNetworkService
        mockNetworkService?.setDefaultHandler { _ in
            return (Data(), HTTPURLResponse(), nil)
        }
    }
    
    // 자세한 목 데이터 설정
    private func setupMockData() {
        guard let mockNetworkService = networkService as? MockNetworkService else { return }
        
        // 계좌 목록 목 데이터
        let accountDTOs: [[String: Any]] = [
            [
                "id": "checking-123",
                "name": "직장인 통장",
                "type": "CHECKING",
                "balance": 1250000,
                "number": "1234-56-7890123",
                "isActive": true
            ],
            [
                "id": "savings-456",
                "name": "비상금 저축",
                "type": "SAVINGS",
                "balance": 5000000,
                "number": "9876-54-3210987",
                "isActive": true
            ],
            [
                "id": "investment-789",
                "name": "주식 계좌",
                "type": "INVESTMENT",
                "balance": 3000000,
                "number": "5678-90-1234567",
                "isActive": true
            ]
        ]
        
        // 거래 내역 목 데이터
        let transactionDTOs: [[String: Any]] = [
            [
                "id": "trans-1",
                "amount": 50000,
                "type": "DEPOSIT",
                "description": "월급",
                "date": Date().addingTimeInterval(-86400).timeIntervalSince1970, // 1일 전
                "isOutgoing": false
            ],
            [
                "id": "trans-2",
                "amount": 15000,
                "type": "WITHDRAWAL",
                "description": "ATM 출금",
                "date": Date().addingTimeInterval(-43200).timeIntervalSince1970, // 12시간 전
                "isOutgoing": true
            ],
            [
                "id": "trans-3",
                "amount": 30000,
                "type": "PAYMENT",
                "description": "카페",
                "date": Date().addingTimeInterval(-21600).timeIntervalSince1970, // 6시간 전
                "isOutgoing": true
            ],
            [
                "id": "trans-4",
                "amount": 100000,
                "type": "TRANSFER",
                "description": "비상금 저축",
                "date": Date().addingTimeInterval(-7200).timeIntervalSince1970, // 2시간 전
                "isOutgoing": false
            ]
        ]
        
        do {
            // 계좌 목록 API 응답 설정
            let accountsJsonData = try JSONSerialization.data(withJSONObject: accountDTOs, options: [])
            mockNetworkService.setRequestHandler(for: "/api/accounts") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/accounts")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (accountsJsonData, response, nil)
            }
            
            // 개별 계좌 상세 API 응답 설정
            for account in accountDTOs {
                guard let accountId = account["id"] as? String else { continue }
                
                let accountJsonData = try JSONSerialization.data(withJSONObject: account, options: [])
                mockNetworkService.setRequestHandler(for: "/api/accounts/\(accountId)") { request in
                    let response = HTTPURLResponse(
                        url: request.url ?? URL(string: "https://example.com/api/accounts/\(accountId)")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json"]
                    )
                    return (accountJsonData, response, nil)
                }
                
                // 계좌별 거래 내역 API 응답 설정
                let transactionsJsonData = try JSONSerialization.data(withJSONObject: transactionDTOs, options: [])
                mockNetworkService.setRequestHandler(for: "/api/accounts/\(accountId)/transactions") { request in
                    let response = HTTPURLResponse(
                        url: request.url ?? URL(string: "https://example.com/api/accounts/\(accountId)/transactions")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json"]
                    )
                    return (transactionsJsonData, response, nil)
                }
            }
            
            print("계좌 및 거래 내역 목 데이터 설정 완료")
        } catch {
            print("목 데이터 설정 오류: \(error.localizedDescription)")
        }
    }
}
