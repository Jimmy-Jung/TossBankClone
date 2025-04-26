import Foundation
import UIKit
import CoordinatorModule
import SwiftUI
import SharedModule

/// 설정 코디네이터 구현
public final class SettingsCoordinator: Coordinator {
    private let navigationController: UINavigationController
    private let diContainer: SettingsDIContainerProtocol
    
    public weak var delegate: SettingsCoordinatorDelegate?
    
    public init(navigationController: UINavigationController, diContainer: SettingsDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }
    
    public func start() {
        showSettings()
    }
    
    // MARK: - 화면 전환 메서드
    
    private func showSettings() {
        // 설정 화면 뷰모델 생성
        let viewModel = SettingsViewModel()
        viewModel.onLogoutButtonTapped = { [weak self] in
            self?.delegate?.settingsCoordinatorDidRequestLogout()
        }
        viewModel.onNotificationCenterTapped = { [weak self] in
            self?.showNotificationCenter()
        }
        
        // SwiftUI 뷰를 UIKit 호스팅 컨트롤러로 래핑
        let settingsView = SettingsView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: settingsView)
        viewController.title = "설정"
        
        // 닫기 버튼 추가
        let closeButton = UIBarButtonItem(
            title: "닫기",
            style: .plain,
            target: self,
            action: #selector(closeButtonTapped)
        )
        viewController.navigationItem.leftBarButtonItem = closeButton
        
        navigationController.setViewControllers([viewController], animated: true)
    }
    
    private func showNotificationCenter() {
        // 알림 센터 화면 전환
        let notificationCenterView = NotificationCenterView()
        let viewController = UIHostingController(rootView: notificationCenterView)
        viewController.title = "알림"
        
        navigationController.pushViewController(viewController, animated: true)
    }
    
    // MARK: - 액션 메서드
    
    @objc private func closeButtonTapped() {
        delegate?.settingsCoordinatorDidFinish()
    }
}

// MARK: - 뷰모델 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

class SettingsViewModel: ObservableObject {
    var onLogoutButtonTapped: (() -> Void)?
    var onNotificationCenterTapped: (() -> Void)?
    
    func handleLogout() {
        onLogoutButtonTapped?()
    }
    
    func handleNotificationCenterTap() {
        onNotificationCenterTapped?()
    }
}

// MARK: - 뷰 임시 구현
// 실제 구현에서는 별도 파일로 분리되어야 함

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        List {
            Section(header: Text("계정")) {
                Button(action: {}) {
                    SettingsRow(title: "내 프로필", icon: "person.fill")
                }
                
                Button(action: {}) {
                    SettingsRow(title: "보안 설정", icon: "lock.fill")
                }
            }
            
            Section(header: Text("알림")) {
                Button(action: {
                    viewModel.handleNotificationCenterTap()
                }) {
                    SettingsRow(title: "알림 센터", icon: "bell.fill")
                }
                
                Button(action: {}) {
                    SettingsRow(title: "알림 설정", icon: "bell.badge.fill")
                }
            }
            
            Section(header: Text("앱 정보")) {
                Button(action: {}) {
                    SettingsRow(title: "앱 버전", icon: "info.circle.fill", value: "1.0.0")
                }
                
                Button(action: {}) {
                    SettingsRow(title: "고객센터", icon: "questionmark.circle.fill")
                }
                
                Button(action: {}) {
                    SettingsRow(title: "이용약관", icon: "doc.text.fill")
                }
            }
            
            Section {
                Button(action: {
                    viewModel.handleLogout()
                }) {
                    Text("로그아웃")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

struct SettingsRow: View {
    let title: String
    let icon: String
    var value: String? = nil
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            
            Text(title)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let value = value {
                Text(value)
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
} 