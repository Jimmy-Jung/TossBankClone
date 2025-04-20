import Foundation

/// 네트워크 연결 상태 플러그인
/// 네트워크 연결 상태를 확인하고 오프라인 상태일 때 요청을 차단합니다.
public class ConnectivityPlugin: NetworkPlugin {
    private let reachability: NetworkReachability
    
    /// 연결 상태 플러그인 초기화
    /// - Parameter reachability: 네트워크 연결 상태 모니터링 객체
    public init(reachability: NetworkReachability) {
        self.reachability = reachability
    }
    
    /// 요청 전 연결 상태 확인
    public func prepare(_ request: inout URLRequest) async throws {
        if !reachability.isConnected {
            throw NetworkError.offline
        }
    }
} 