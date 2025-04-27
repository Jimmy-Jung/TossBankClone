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

public final class TransferDIContainer: TransferDIContainerProtocol {
    // MARK: - 속성
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL
    
    // MARK: - 초기화
    public init(
        networkService: NetworkServiceProtocol,
        baseURL: URL
    ) {
        self.networkService = networkService
        self.baseURL = baseURL
    }

    private func createAPIClient() -> APIClient {
        return NetworkAPIClient(networkService: networkService, baseURL: baseURL)
    }
}
