import Foundation

/// 인증 플러그인
/// API 요청에 인증 토큰을 추가하고 인증 관련 응답을 처리합니다.
public class AuthPlugin: NetworkPlugin {
    private let tokenProvider: () -> String?
    
    /// 인증 플러그인 초기화
    /// - Parameter tokenProvider: 인증 토큰을 제공하는 클로저
    public init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    /// 요청 전처리 - 인증 토큰 추가
    public func prepare(_ request: inout URLRequest) async throws {
        // 토큰이 있는 경우에만 헤더에 추가
        if let token = tokenProvider() {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    /// 응답 처리 - 인증 오류 처리
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 인증 관련 응답 처리 (예: 401 Unauthorized)
        if response.statusCode == 401 {
            // 토큰 만료 등의 처리가 필요한 경우
            throw NetworkError.unauthorized
        }
    }
} 