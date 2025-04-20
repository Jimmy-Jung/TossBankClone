import Foundation

/// 로깅 플러그인
/// 네트워크 요청 및 응답을 로깅합니다.
public class LoggingPlugin: NetworkPlugin {
    private let logLevel: LogLevel
    
    /// 로그 레벨
    public enum LogLevel {
        case none
        case basic    // URL, 상태 코드만
        case headers  // URL, 상태 코드, 헤더
        case body     // URL, 상태 코드, 헤더, 바디
    }
    
    /// 로깅 플러그인 초기화
    /// - Parameter logLevel: 로그 레벨 (기본값: .basic)
    public init(logLevel: LogLevel = .basic) {
        self.logLevel = logLevel
    }
    
    /// 요청 로깅
    public func prepare(_ request: inout URLRequest) async throws {
        guard logLevel != .none else { return }
        
        print("🌐 [REQUEST] \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        if logLevel == .headers || logLevel == .body {
            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                print("📋 [HEADERS]")
                headers.forEach { print("   \($0.key): \($0.value)") }
            }
        }
        
        if logLevel == .body, let body = request.httpBody, let json = try? JSONSerialization.jsonObject(with: body) {
            print("📦 [BODY]")
            print("   \(json)")
        }
    }
    
    /// 응답 로깅
    public func process(_ request: URLRequest, _ response: HTTPURLResponse, _ data: Data) async throws {
        guard logLevel != .none else { return }
        
        print("📲 [RESPONSE] [\(response.statusCode)] \(request.url?.absoluteString ?? "")")
        
        if logLevel == .headers || logLevel == .body {
            print("📋 [HEADERS]")
            response.allHeaderFields.forEach { print("   \($0.key): \($0.value)") }
        }
        
        if logLevel == .body, !data.isEmpty {
            if let json = try? JSONSerialization.jsonObject(with: data) {
                print("📦 [BODY]")
                print("   \(json)")
            } else if let text = String(data: data, encoding: .utf8) {
                print("📦 [BODY]")
                print("   \(text)")
            }
        }
    }
} 