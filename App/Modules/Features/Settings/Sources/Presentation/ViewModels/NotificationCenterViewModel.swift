//
//  NotificationCenterViewModel.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import Combine
import SharedModule

class NotificationCenterViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var filteredNotifications: [AppNotification] = []
    
    private let notificationManager = NotificationManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 알림 관리자 구독
        notificationManager.notificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                self?.notifications = notifications
                self?.filterNotifications(by: nil)
            }
            .store(in: &cancellables)
    }
    
    func loadNotifications() {
        notifications = notificationManager.notifications
        filteredNotifications = notifications
    }
    
    func filterNotifications(by type: NotificationType?) {
        if let type = type {
            filteredNotifications = notifications.filter { $0.type == type }
        } else {
            filteredNotifications = notifications
        }
    }
    
    func markAsRead(id: String) {
        notificationManager.markAsRead(id: id)
    }
    
    func markAllAsRead() {
        notificationManager.markAllAsRead()
    }
    
    func handleNotificationTap(_ notification: AppNotification) {
        // 알림 타입별 처리
        switch notification.type {
        case .transaction:
            if let transactionId = notification.data?["transactionId"] {
                navigateToTransaction(transactionId)
            }
        case .security:
            navigateToSecuritySettings()
        case .marketing:
            if let campaignId = notification.data?["campaignId"] {
                navigateToCampaign(campaignId)
            }
        case .system:
            navigateToSystemSettings()
        }
    }
    
    // 화면 전환 메서드
    private func navigateToTransaction(_ id: String) {
        print("거래 내역 화면으로 이동: \(id)")
        // 실제 구현에서는 NavigationCoordinator를 통해 화면 전환
    }
    
    private func navigateToSecuritySettings() {
        print("보안 설정 화면으로 이동")
    }
    
    private func navigateToCampaign(_ id: String) {
        print("캠페인 화면으로 이동: \(id)")
    }
    
    private func navigateToSystemSettings() {
        print("시스템 설정 화면으로 이동")
    }
}
