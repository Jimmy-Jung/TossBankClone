import Foundation

/// 네트워크 요청 재시도 플러그인
/// 실패한 네트워크 요청을 자동으로 재시도합니다.
public class RetryPlugin: NetworkPlugin {
    /// 재시도 설정
    public struct Configuration {
        /// 최대 재시도 횟수
        let maxRetries: Int
        
        /// 기본 지연 시간 (초)
        let baseDelay: TimeInterval
        
        /// 지연 시간 승수 (지수 백오프 적용을 위한 값)
        let delayMultiplier: Double
        
        /// 최대 지연 시간 (초)
        let maxDelay: TimeInterval
        
        /// 재시도 가능한 오류인지 확인하는 함수
        let isRetryableError: (Error) -> Bool
        
        /// 기본 설정으로 초기화
        /// - Parameters:
        ///   - maxRetries: 최대 재시도 횟수 (기본값: 3)
        ///   - baseDelay: 기본 지연 시간 (초) (기본값: 1.0)
        ///   - delayMultiplier: 지연 시간 승수 (지수 백오프 적용을 위한 값) (기본값: 2.0)
        ///   - maxDelay: 최대 지연 시간 (초) (기본값: 10.0)
        ///   - isRetryableError: 재시도 가능한 오류인지 확인하는 함수 (기본값: NetworkError.isRetryable)
        public init(
            maxRetries: Int = 3,
            baseDelay: TimeInterval = 1.0,
            delayMultiplier: Double = 2.0,
            maxDelay: TimeInterval = 10.0,
            isRetryableError: @escaping (Error) -> Bool = { error in
                if let networkError = error as? NetworkError {
                    return networkError.isRetryable
                }
                return false
            }
        ) {
            self.maxRetries = maxRetries
            self.baseDelay = baseDelay
            self.delayMultiplier = delayMultiplier
            self.maxDelay = maxDelay
            self.isRetryableError = isRetryableError
        }
    }
    
    /// 플러그인 설정
    private let configuration: Configuration
    
    /// 현재 진행 중인 재시도 정보를 저장하기 위한 캐시
    private var retryCountCache: [String: Int] = [:]
    
    /// RetryPlugin 초기화
    /// - Parameter configuration: 재시도 설정
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    /// 요청에 대한 고유 키 생성
    private func requestKey(_ request: URLRequest) -> String {
        return [
            request.url?.absoluteString ?? "",
            request.httpMethod ?? "",
            String(request.hashValue)
        ].joined(separator: "-")
    }
    
    /// 지수 백오프를 이용한 지연 시간 계산
    private func calculateDelay(for retryCount: Int) -> TimeInterval {
        let delay = configuration.baseDelay * pow(configuration.delayMultiplier, Double(retryCount))
        return min(delay, configuration.maxDelay)
    }
    
    // NetworkPlugin 프로토콜 구현
    public func prepare(_ request: inout URLRequest) async throws {
        // 요청 전에는 특별한 처리 없음
    }
    
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        // 성공적인 응답인 경우 재시도 카운트 초기화
        if (200...299).contains(response.statusCode) {
            let key = requestKey(request)
            retryCountCache[key] = nil
            return
        }
        
        // 오류 상태 코드인 경우
        let key = requestKey(request)
        let currentRetry = retryCountCache[key] ?? 0
        
        // 재시도 횟수 초과 시 캐시 초기화하고 오류 전달
        if currentRetry >= configuration.maxRetries {
            retryCountCache[key] = nil
            
            let error = NetworkError.httpError(statusCode: response.statusCode, data: data)
            if !configuration.isRetryableError(error) {
                throw error
            }
            
            throw error
        }
        
        // 오류가 재시도 가능한 경우
        let error = NetworkError.httpError(statusCode: response.statusCode, data: data)
        if configuration.isRetryableError(error) {
            // 재시도 카운트 증가
            retryCountCache[key] = currentRetry + 1
            
            // 지연 시간 계산
            let delay = calculateDelay(for: currentRetry)
            
            // 지연 시간 대기
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            
            // 재시도 로직은 호출자가 다시 시도하도록 오류 발생
            throw error
        } else {
            // 재시도 불가능한 오류인 경우 캐시 초기화하고 오류 전달
            retryCountCache[key] = nil
            throw error
        }
    }
} 