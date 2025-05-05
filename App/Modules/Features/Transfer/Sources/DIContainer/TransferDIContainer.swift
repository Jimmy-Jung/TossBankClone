//
//  TransferDIContainer.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import NetworkModule
import SharedModule
import DomainModule

public final class TransferDIContainer: TransferDIContainerProtocol {
    // MARK: - 속성
    private let environment: AppEnvironment
    private let networkService: NetworkServiceProtocol
    
    // MARK: - 초기화
    public init(
        environment: AppEnvironment,
        networkService: NetworkServiceProtocol
    ) {
        self.environment = environment
        self.networkService = networkService
        
        if environment == .test {
            setupMockData()
        }
    }

    private func createAPIClient() -> APIClient {
        return NetworkAPIClient(networkService: networkService)
    }
    
    // 뷰모델 생성 메서드
    public func makeTransferAmountViewModel(accountId: String) -> any AsyncViewModel {
        return TransferAmountViewModel(accountId: accountId)
    }
    
    public func makeTransferConfirmViewModel(
        sourceAccountId: String,
        amount: Double,
        receiverAccount: BankAccount
    ) -> any AsyncViewModel {
        return TransferConfirmViewModel(
            sourceAccountId: sourceAccountId,
            amount: amount,
            receiverAccount: receiverAccount
        )
    }
    
    public func makeTransferResultViewModel(success: Bool) -> any AsyncViewModel {
        return TransferResultViewModel(success: success)
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
        
        // 계좌 목 데이터
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
            ]
        ]
        
        // 최근 송금 계좌 목 데이터
        let recentAccountDTOs: [[String: Any]] = [
            [
                "id": "recent-100",
                "name": "친구 계좌",
                "type": "CHECKING",
                "balance": 0,
                "number": "110-123-456789",
                "bankName": "신한은행",
                "isActive": true
            ],
            [
                "id": "recent-101",
                "name": "가족 계좌",
                "type": "CHECKING",
                "balance": 0,
                "number": "123-45-6789012",
                "bankName": "국민은행",
                "isActive": true
            ],
            [
                "id": "recent-102",
                "name": "회사 계좌",
                "type": "CHECKING",
                "balance": 0,
                "number": "1002-456-789012",
                "bankName": "우리은행",
                "isActive": true
            ]
        ]
        
        // 송금 결과 목 데이터
        let transferResultDTO: [String: Any] = [
            "transactionId": "T12345",
            "timestamp": Date().timeIntervalSince1970,
            "amount": 50000,
            "sourceAccountId": "checking-123",
            "destinationAccountId": "recent-100",
            "status": "SUCCESS",
            "fee": 0
        ]
        
        do {
            // 계좌 정보 API 응답 설정
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
            }
            
            // 최근 송금 계좌 목록 API 응답 설정
            let recentAccountsJsonData = try JSONSerialization.data(withJSONObject: recentAccountDTOs, options: [])
            mockNetworkService.setRequestHandler(for: "/api/transfer/recent-accounts") { request in
                let response = HTTPURLResponse(
                    url: request.url ?? URL(string: "https://example.com/api/transfer/recent-accounts")!,
                    statusCode: 200,
                    httpVersion: nil,
                    headerFields: ["Content-Type": "application/json"]
                )
                return (recentAccountsJsonData, response, nil)
            }
            
            // 송금 요청 API 응답 설정
            let transferResultJsonData = try JSONSerialization.data(withJSONObject: transferResultDTO, options: [])
            mockNetworkService.setRequestHandler(for: "/api/transfer") { request in
                // POST 요청 확인
                if request.httpMethod == "POST" {
                    let response = HTTPURLResponse(
                        url: request.url ?? URL(string: "https://example.com/api/transfer")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: ["Content-Type": "application/json"]
                    )
                    return (transferResultJsonData, response, nil)
                }
                
                return (Data(), HTTPURLResponse(), nil)
            }
            
            print("송금 테스트 데이터 설정 완료")
        } catch {
            print("송금 목 데이터 설정 오류: \(error.localizedDescription)")
        }
    }
}
