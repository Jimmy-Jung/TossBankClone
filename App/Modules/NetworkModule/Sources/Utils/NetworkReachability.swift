import Foundation
import Network

/// 네트워크 연결 상태 모니터링 프로토콜
public protocol NetworkReachability {
    /// 현재 네트워크 연결 여부
    var isConnected: Bool { get }
    
    /// 네트워크 상태 변경 콜백
    var didChangeStatus: ((Bool) -> Void)? { get set }
}

/// 네트워크 연결 상태 모니터링 구현체
public final class NetworkReachabilityImpl: NetworkReachability {
    // MARK: - 싱글톤
    public static let shared = NetworkReachabilityImpl()
    
    // MARK: - 속성
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    
    public private(set) var isConnected: Bool = true
    public var didChangeStatus: ((Bool) -> Void)?
    
    // MARK: - 초기화
    public init() {
        self.monitor = NWPathMonitor()
        self.queue = DispatchQueue(label: "NetworkReachabilityMonitor")
        
        setupMonitor()
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - 메서드
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            self?.updateConnectionStatus(isConnected)
        }
        
        monitor.start(queue: queue)
    }
    
    private func updateConnectionStatus(_ isConnected: Bool) {
        if self.isConnected != isConnected {
            DispatchQueue.main.async {
                self.isConnected = isConnected
                self.didChangeStatus?(isConnected)
            }
        }
    }
} 