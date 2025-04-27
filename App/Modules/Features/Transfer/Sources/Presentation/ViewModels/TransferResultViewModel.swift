//
//  TransferResultViewModel.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import Foundation
import SharedModule

public final class TransferResultViewModel: AsyncViewModel {
    // Input 열거형 정의
    public enum Input {
        case viewDidLoad
        case doneButtonTapped
    }
    
    // Action 열거형 정의
    public enum Action {
        case finishTransfer
    }
    
    // 상태 프로퍼티
    let success: Bool
    let transactionId: String
    @Published var error: Error?
    
    var onDoneButtonTapped: (() -> Void)?
    
    public init(success: Bool) {
        self.success = success
        self.transactionId = "T\(Int.random(in: 10000...99999))"
    }
    
    public func transform(_ input: Input) async -> [Action] {
        switch input {
        case .viewDidLoad:
            return []
        case .doneButtonTapped:
            return [.finishTransfer]
        }
    }
    
    public func perform(_ action: Action) async throws {
        switch action {
        case .finishTransfer:
            try await handleDoneButton()
        }
    }
    
    public func handleError(_ error: Error) async {
        self.error = error
        print("Error: \(error.localizedDescription)")
    }
    
    // MARK: - Action Methods
    
    func handleDoneButton() async throws {
        if let callback = onDoneButtonTapped {
            await MainActor.run {
                callback()
            }
        }
    }
} 