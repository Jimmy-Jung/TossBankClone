import Foundation
import UIKit
import CoordinatorModule

/// 홈 코디네이터 구현
public final class HomeCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: AccountDIContainerProtocol
    
    public init(navigationController: UINavigationController, diContainer: AccountDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        // TODO: 홈 화면 구현 코드가 추가될 예정
    }
}

/// 송금 코디네이터 구현
public final class TransferCoordinator: NSObject, Coordinator {
    public let navigationController: UINavigationController
    private let diContainer: TransferDIContainerProtocol
    
    public init(navigationController: UINavigationController, diContainer: TransferDIContainerProtocol) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        super.init()
    }
    
    public func start() {
        // TODO: 송금 화면 구현 코드가 추가될 예정
    }
} 