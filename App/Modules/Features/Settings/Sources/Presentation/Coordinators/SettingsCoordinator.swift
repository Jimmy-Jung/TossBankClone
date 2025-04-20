import Foundation
import UIKit
import CoordinatorModule

/// 설정 코디네이터 구현
public final class SettingsCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
    
    public func start() {
        // TODO: 설정 화면 구현 코드가 추가될 예정
    }
} 