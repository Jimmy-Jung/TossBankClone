//
//  NotificationCenterView.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import Combine
import SharedModule

struct NotificationCenterView: View {
    @StateObject private var viewModel = NotificationCenterViewModel()
    @State private var selectedFilter: NotificationType?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 필터 버튼
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    filterButton(title: "전체", type: nil)
                    
                    ForEach([NotificationType.transaction, 
                             NotificationType.security,
                             NotificationType.system,
                             NotificationType.marketing], id: \.rawValue) { type in
                        filterButton(title: type.displayName, type: type)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 8)
            
            Divider()
            
            // 알림 목록
            if viewModel.filteredNotifications.isEmpty {
                emptyNotificationView
            } else {
                notificationListView
            }
        }
        .navigationTitle("알림")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("모두 읽음") {
                    viewModel.markAllAsRead()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .disabled(viewModel.filteredNotifications.isEmpty)
            }
        }
        .onAppear {
            viewModel.loadNotifications()
        }
    }
    
    // 필터 버튼 뷰
    private func filterButton(title: String, type: NotificationType?) -> some View {
        Button(action: {
            selectedFilter = type
            viewModel.filterNotifications(by: type)
        }) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selectedFilter == type ? Color.accentColor : Color.gray.opacity(0.1))
                )
                .foregroundColor(selectedFilter == type ? .white : .primary)
        }
    }
    
    // 알림 목록 뷰
    private var notificationListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredNotifications) { notification in
                    NotificationCell(notification: notification) {
                        viewModel.markAsRead(id: notification.id)
                        viewModel.handleNotificationTap(notification)
                    }
                    
                    Divider()
                }
            }
        }
    }
    
    // 빈 알림 뷰
    private var emptyNotificationView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("알림이 없습니다")
                .font(.headline)
                .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

// 유틸리티 확장
extension NotificationType {
    var displayName: String {
        switch self {
        case .transaction: return "거래"
        case .security: return "보안"
        case .marketing: return "혜택"
        case .system: return "시스템"
        }
    }
}
