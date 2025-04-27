//
//  NotificationCell.swift
//  SettingsFeature
//
//  Created by 정준영 on 2025/4/27.
//  Copyright © 2025 TossBank. All rights reserved.
//

import SwiftUI
import Combine
import SharedModule

struct NotificationCell: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // 알림 타입 아이콘
                notificationIcon
                    .frame(width: 40, height: 40)
                    .background(notificationBackgroundColor.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 8) {
                    // 제목 및 시간
                    HStack {
                        Text(notification.title)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(notification.timestamp.timeAgo)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 메시지
                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // 읽지 않은 알림 표시
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(16)
            .background(notification.isRead ? Color.clear : Color.blue.opacity(0.05))
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 알림 타입별 아이콘
    private var notificationIcon: some View {
        Group {
            switch notification.type {
            case .transaction:
                Image(systemName: "creditcard")
                    .foregroundColor(.blue)
            case .security:
                Image(systemName: "lock.shield")
                    .foregroundColor(.red)
            case .marketing:
                Image(systemName: "megaphone")
                    .foregroundColor(.orange)
            case .system:
                Image(systemName: "gear")
                    .foregroundColor(.gray)
            }
        }
        .font(.system(size: 16, weight: .semibold))
    }
    
    // 알림 타입별 배경색
    private var notificationBackgroundColor: Color {
        switch notification.type {
        case .transaction: return .blue
        case .security: return .red
        case .marketing: return .orange
        case .system: return .gray
        }
    }
}
