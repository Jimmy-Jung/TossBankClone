//
//  TransferCoordinator.swift
//  TransferFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import UIKit
import SwiftUI
import DomainModule
import SharedModule

/// 송금 코디네이터 구현
public final class TransferCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: TransferDIContainerProtocol
    private let sourceAccountId: String
    
    public weak var delegate: TransferCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, 
                diContainer: TransferDIContainerProtocol,
                sourceAccountId: String) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.sourceAccountId = sourceAccountId
    }
    
    public func start() {
        showTransferAmount()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showTransferAmount() {
        // 송금 금액 화면 뷰모델 생성
        let viewModel = diContainer.makeTransferAmountViewModel(accountId: sourceAccountId) as! TransferAmountViewModel
        viewModel.onContinueButtonTapped = { [weak self] amount, receiverAccount in
            self?.showTransferConfirmation(amount: amount, receiverAccount: receiverAccount)
        }
        viewModel.onCancelButtonTapped = { [weak self] in
            self?.delegate?.transferCoordinatorDidCancel()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let transferView = TransferAmountView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: transferView)
        viewController.title = "송금하기"
        
        // 취소 버튼 추가
        let cancelButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = cancelButton
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showTransferConfirmation(amount: Double, receiverAccount: BankAccount) {
        // 송금 확인 화면 뷰모델 생성
        let viewModel = diContainer.makeTransferConfirmViewModel(
            sourceAccountId: sourceAccountId,
            amount: amount,
            receiverAccount: receiverAccount
        ) as! TransferConfirmViewModel
        
        viewModel.onTransferButtonTapped = { [weak self] in
            self?.showTransferResult(success: true)
        }
        viewModel.onCancelButtonTapped = { [weak self] in
            self?.showTransferAmount()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let confirmView = TransferConfirmView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: confirmView)
        viewController.title = "송금 확인"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    private func showTransferResult(success: Bool) {
        // 송금 결과 화면 뷰모델 생성
        let viewModel = diContainer.makeTransferResultViewModel(success: success) as! TransferResultViewModel
        viewModel.onDoneButtonTapped = { [weak self] in
            self?.delegate?.transferCoordinatorDidFinish()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let resultView = TransferResultView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: resultView)
        viewController.title = success ? "송금 완료" : "송금 실패"
        
        // 네비게이션 바 숨기기
        viewController.navigationItem.hidesBackButton = true
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func cancelButtonTapped() {
        delegate?.transferCoordinatorDidCancel()
    }
}

