//
//  AccountCoordinator.swift
//  AccountFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import UIKit
import SwiftUI
import DomainModule
import DataModule
import SharedModule
import NetworkModule

/// 계좌 코디네이터 구현
public final class AccountCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: AccountDIContainerProtocol
    
    public weak var delegate: AccountCoordinatorDelegate?
    
    public init(
        navigationController: UINavigationController,
        diContainer: AccountDIContainerProtocol
    ) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    public func start() {
        showAccountList()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showAccountList() {
        // 계좌 목록 뷰모델 생성
        guard let viewModel = diContainer.makeAccountListViewModel() as? AccountListViewModel else {
            return
        }
        
        // 계좌 선택 시 호출될 콜백 설정
        viewModel.onAccountSelected = { [weak self] accountId in
            self?.showAccountDetail(accountId: accountId)
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let accountListView = AccountListView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: accountListView)
        viewController.title = "계좌"
        
        // 네비게이션 바 아이템 설정
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        viewController.navigationItem.rightBarButtonItem = settingsButton
        
        // 탭 바 아이템 설정
        viewController.tabBarItem = UITabBarItem(
            title: "계좌",
            image: UIImage(systemName: "creditcard"),
            selectedImage: UIImage(systemName: "creditcard.fill")
        )
        
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    public func showAccountDetail(accountId: String) {
        // 계좌 상세 뷰모델 생성
        guard let viewModel = diContainer.makeAccountDetailViewModel(accountId: accountId) as? AccountDetailViewModel else {
            return
        }
        
        // 송금 버튼 탭 이벤트 처리
        viewModel.onTransferRequested = { [weak self] in
            self?.delegate?.accountCoordinatorDidRequestTransfer(fromAccountId: accountId)
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let accountDetailView = AccountDetailView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: accountDetailView)
        viewController.title = "계좌 상세"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func settingsButtonTapped() {
        delegate?.accountCoordinatorDidRequestSettings()
    }
}
