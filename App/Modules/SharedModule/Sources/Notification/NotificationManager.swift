import Foundation
import UIKit
import UserNotifications
import Combine

/// 알림 유형 정의
public enum NotificationType: String, Codable {
    case transaction = "transaction"  // 거래 알림
    case security = "security"        // 보안 알림
    case marketing = "marketing"      // 마케팅 알림
    case system = "system"            // 시스템 알림
}

/// 알림 모델
public struct AppNotification: Identifiable, Codable {
    public let id: String
    public let type: NotificationType
    public let title: String
    public let message: String
    public let timestamp: Date
    public let data: [String: String]?
    public var isRead: Bool
    
    public init(id: String = UUID().uuidString,
                type: NotificationType,
                title: String,
                message: String,
                timestamp: Date = Date(),
                data: [String: String]? = nil,
                isRead: Bool = false) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.timestamp = timestamp
        self.data = data
        self.isRead = isRead
    }
}

/// 알림 관리자 프로토콜
public protocol NotificationManagerProtocol {
    // 앱 내 알림 관련
    var notifications: [AppNotification] { get }
    var unreadCount: Int { get }
    var notificationsPublisher: AnyPublisher<[AppNotification], Never> { get }
    
    func addNotification(_ notification: AppNotification)
    func markAsRead(id: String)
    func markAllAsRead()
    func removeNotification(id: String)
    func clearAllNotifications()
    
    // 푸시 알림 관련
    func registerForPushNotifications()
    func handlePushNotification(userInfo: [AnyHashable: Any])
    
    // 알림 설정 관련
    func isEnabled(for type: NotificationType) -> Bool
    func setEnabled(_ enabled: Bool, for type: NotificationType)
}

/// 알림 관리자 구현
public final class NotificationManager: NSObject, NotificationManagerProtocol {
    // MARK: - 싱글톤 인스턴스
    public static let shared = NotificationManager()
    
    // MARK: - 속성
    private let notificationCenter = UNUserNotificationCenter.current()
    private let userDefaults = UserDefaults.standard
    
    @Published private var _notifications: [AppNotification] = []
    public var notifications: [AppNotification] { _notifications }
    public var notificationsPublisher: AnyPublisher<[AppNotification], Never> {
        $_notifications.eraseToAnyPublisher()
    }
    
    public var unreadCount: Int {
        _notifications.filter { !$0.isRead }.count
    }
    
    private var notificationSettings: [String: Bool] = [:]
    private let notificationSettingsKey = "app.notification.settings"
    
    // MARK: - 초기화
    private override init() {
        super.init()
        loadSettings()
        loadNotifications()
    }
    
    private func loadSettings() {
        // 저장된 알림 설정 로드
        if let savedSettings = userDefaults.dictionary(forKey: notificationSettingsKey) as? [String: Bool] {
            notificationSettings = savedSettings
        } else {
            // 기본 설정 초기화
            notificationSettings = [
                NotificationType.transaction.rawValue: true,
                NotificationType.security.rawValue: true,
                NotificationType.marketing.rawValue: false,
                NotificationType.system.rawValue: true
            ]
            saveNotificationSettings()
        }
    }
    
    // MARK: - 앱 내 알림 관련 메서드
    public func addNotification(_ notification: AppNotification) {
        // 새 알림을 목록 앞쪽에 추가 (최신순)
        _notifications.insert(notification, at: 0)
        saveNotifications()
        
        // 해당 유형의 알림이 활성화되어 있으면 로컬 푸시 알림도 전송
        if isEnabled(for: notification.type) {
            sendLocalNotification(for: notification)
        }
    }
    
    public func markAsRead(id: String) {
        if let index = _notifications.firstIndex(where: { $0.id == id }) {
            _notifications[index].isRead = true
            saveNotifications()
        }
    }
    
    public func markAllAsRead() {
        for i in 0..<_notifications.count {
            _notifications[i].isRead = true
        }
        saveNotifications()
    }
    
    public func removeNotification(id: String) {
        _notifications.removeAll(where: { $0.id == id })
        saveNotifications()
    }
    
    public func clearAllNotifications() {
        _notifications.removeAll()
        saveNotifications()
    }
    
    // MARK: - 푸시 알림 관련 메서드
    public func registerForPushNotifications() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            
            if let error = error {
                print("푸시 알림 권한 요청 오류: \(error)")
            }
        }
    }
    
    public func handlePushNotification(userInfo: [AnyHashable : Any]) {
        // 푸시 알림 데이터 파싱
        guard let title = userInfo["title"] as? String,
              let message = userInfo["message"] as? String,
              let typeRaw = userInfo["type"] as? String,
              let type = NotificationType(rawValue: typeRaw) else {
            return
        }
        
        // 추가 데이터 추출
        var data: [String: String]? = nil
        if let payloadData = userInfo["data"] as? [String: String] {
            data = payloadData
        }
        
        // 앱 내 알림으로 변환 및 추가
        let notification = AppNotification(
            type: type,
            title: title,
            message: message,
            data: data
        )
        
        addNotification(notification)
    }
    
    // MARK: - 알림 설정 관련 메서드
    public func isEnabled(for type: NotificationType) -> Bool {
        return notificationSettings[type.rawValue] ?? true
    }
    
    public func setEnabled(_ enabled: Bool, for type: NotificationType) {
        notificationSettings[type.rawValue] = enabled
        saveNotificationSettings()
    }
    
    // MARK: - 내부 헬퍼 메서드
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(_notifications) {
            userDefaults.set(encoded, forKey: "app.notifications")
        }
    }
    
    private func loadNotifications() {
        if let savedData = userDefaults.data(forKey: "app.notifications"),
           let decoded = try? JSONDecoder().decode([AppNotification].self, from: savedData) {
            _notifications = decoded
        }
    }
    
    private func saveNotificationSettings() {
        userDefaults.set(notificationSettings, forKey: notificationSettingsKey)
    }
    
    private func sendLocalNotification(for notification: AppNotification) {
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.message
        content.sound = .default
        
        if let data = notification.data {
            content.userInfo = Dictionary(uniqueKeysWithValues: data.map { ($0.key, $0.value) })
        }
        
        let request = UNNotificationRequest(
            identifier: notification.id,
            content: content,
            trigger: nil  // 즉시 표시
        )
        
        notificationCenter.add(request)
    }
} 
