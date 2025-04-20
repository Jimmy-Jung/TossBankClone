import Foundation

/// 타임아웃 플러그인
/// 네트워크 요청에 타임아웃을 설정합니다.
public class TimeoutPlugin: NetworkPlugin {
    private let timeout: TimeInterval
    
    /// 타임아웃 플러그인 초기화
    /// - Parameter timeout: 타임아웃 시간(초) (기본값: 30.0)
    public init(timeout: TimeInterval = 30.0) {
        self.timeout = timeout
    }
    
    /// 요청에 타임아웃 설정
    public func prepare(_ request: inout URLRequest) async throws {
        request.timeoutInterval = timeout
    }
} 