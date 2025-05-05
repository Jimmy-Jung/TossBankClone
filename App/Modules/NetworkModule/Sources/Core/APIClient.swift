import Foundation
import Combine

/// API 클라이언트 프로토콜
public protocol APIClient {
    /// API 요청 실행
    /// - Parameter request: API 요청
    /// - Returns: API 응답
    func send<T: APIRequest>(_ request: T) async throws -> T.Response
}

/// 네트워크 서비스 기반 API 클라이언트 구현
public final class NetworkAPIClient: APIClient {
    // MARK: - 속성
    private let networkService: NetworkServiceProtocol
    
    // MARK: - 생성자
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    // MARK: - APIClient 프로토콜 구현
    public func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        do {
            return try await networkService.request(request)
        } catch {
            throw error
        }
    }
} 
