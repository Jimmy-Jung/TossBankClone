import Foundation

/// 네트워크 플러그인 인터페이스
/// 네트워크 요청과 응답을 가로채고 처리하기 위한 인터페이스입니다.
public protocol NetworkPlugin {
    /// 요청 전처리
    /// - Parameter request: 수정할 URLRequest
    /// - Throws: 네트워크 오류
    func prepare(_ request: inout URLRequest) async throws
    
    /// 응답 후처리
    /// - Parameters:
    ///   - request: 원본 요청
    ///   - response: HTTP 응답
    ///   - data: 응답 데이터
    /// - Throws: 네트워크 오류
    func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws
}

/// NetworkPlugin 기본 구현
public extension NetworkPlugin {
    /// 요청 전처리
    func prepare(_ request: inout URLRequest) async throws {
        // 기본 구현은 요청을 수정하지 않습니다.
    }
    
    /// 응답 후처리
    func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 기본 구현은 응답을 수정하지 않습니다.
    }
} 