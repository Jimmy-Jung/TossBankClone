import Foundation

/// 캐시 플러그인
/// 네트워크 요청 결과를 캐싱하고 캐시된 결과를 사용합니다.
public class CachePlugin: NetworkPlugin {
    private let cache: URLCache
    private let cachePolicy: URLRequest.CachePolicy
    
    /// 캐시 플러그인 초기화
    /// - Parameters:
    ///   - cache: 사용할 URLCache 인스턴스 (기본값: .shared)
    ///   - cachePolicy: 캐시 정책 (기본값: .returnCacheDataElseLoad)
    public init(
        cache: URLCache = .shared,
        cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad
    ) {
        self.cache = cache
        self.cachePolicy = cachePolicy
    }
    
    /// 요청에 캐시 정책 적용
    public func prepare(_ request: inout URLRequest) async throws {
        // GET 요청에만 캐싱 적용
        if request.httpMethod == "GET" {
            request.cachePolicy = cachePolicy
        }
    }
    
    /// 응답 캐싱
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 캐시 가능한 응답만 저장
        if request.httpMethod == "GET" && (200...299).contains(response.statusCode) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
    }
} 