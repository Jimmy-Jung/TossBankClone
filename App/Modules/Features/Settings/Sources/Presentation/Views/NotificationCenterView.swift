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

// 알림 셀 뷰
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

// 알림 센터 ViewModel
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

extension Date {
    var timeAgo: String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: self, to: now)
        
        if let day = components.day, day > 0 {
            if day > 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy.MM.dd"
                return formatter.string(from: self)
            }
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else {
            return "방금"
        }
    }
} 