import Foundation

/// 네트워크 오류 정의
public enum NetworkError: Error, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case decodingError(Error)
    case connectionError(Error)
    case timeoutError
    case unauthorized
    case offline
    case noData
    case serverError(statusCode: Int, data: Data?)
    case noInternetConnection
    case unknownError(Error)
    
    /// 재시도 가능한 에러인지 확인
    public var isRetryable: Bool {
        switch self {
        case .connectionError, .timeoutError, .offline, .noInternetConnection:
            return true
        case .httpError(let statusCode, _), .serverError(let statusCode, _):
            return (500...599).contains(statusCode)
        default:
            return false
        }
    }
    
    /// 사용자에게 표시할 에러 메시지
    public var userMessage: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL 형식입니다."
        case .invalidResponse:
            return "서버에서 유효하지 않은 응답을 받았습니다."
        case .httpError(let statusCode, _), .serverError(let statusCode, _):
            switch statusCode {
            case 400: return "잘못된 요청입니다."
            case 401: return "로그인이 필요합니다."
            case 403: return "접근 권한이 없습니다."
            case 404: return "요청한 정보를 찾을 수 없습니다."
            case 500...599: return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            default: return "오류가 발생했습니다. (코드: \(statusCode))"
            }
        case .decodingError:
            return "데이터 처리 중 오류가 발생했습니다."
        case .connectionError:
            return "네트워크 연결에 문제가 있습니다."
        case .timeoutError:
            return "요청 시간이 초과되었습니다."
        case .unauthorized:
            return "인증이 필요합니다. 다시 로그인해주세요."
        case .offline, .noInternetConnection:
            return "인터넷 연결이 오프라인 상태입니다."
        case .noData:
            return "서버에서 데이터를 받지 못했습니다."
        case .unknownError(let error):
            return "알 수 없는 오류가 발생했습니다. 자세한 내용은 로그를 확인해주세요. 오류: \(error)"
        }
    }
    
    // MARK: - Equatable 구현
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.timeoutError, .timeoutError),
             (.unauthorized, .unauthorized),
             (.offline, .offline),
             (.noData, .noData),
             (.noInternetConnection, .noInternetConnection):
            return true
            
        case (.httpError(let lhsCode, _), .httpError(let rhsCode, _)):
            return lhsCode == rhsCode
            
        case (.serverError(let lhsCode, _), .serverError(let rhsCode, _)):
            return lhsCode == rhsCode
            
        case (.decodingError, .decodingError),
             (.connectionError, .connectionError),
             (.unknownError, .unknownError):
            // Error 프로토콜은 Equatable을 준수하지 않으므로 타입만 같으면 동일하다고 처리
            return true
            
        default:
            return false
        }
    }
} 