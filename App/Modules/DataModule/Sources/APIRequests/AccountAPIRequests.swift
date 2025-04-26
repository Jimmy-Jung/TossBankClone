import Foundation
import NetworkModule
import DomainModule

/// 계좌 목록 요청
struct AccountListRequest: APIRequest {
    typealias Response = [AccountDTO]
    
    var path: String { return "/api/accounts" }
    var method: HTTPMethod { return .get }
}

/// 계좌 상세 요청
struct AccountDetailRequest: APIRequest {
    typealias Response = AccountDTO
    
    let accountId: String
    
    var path: String { return "/api/accounts/\(accountId)" }
    var method: HTTPMethod { return .get }
}

/// 계좌 거래내역 요청
struct TransactionListRequest: APIRequest {
    typealias Response = [TransactionDTO]
    
    let accountId: String
    let limit: Int
    let offset: Int
    
    var path: String { return "/api/accounts/\(accountId)/transactions" }
    var method: HTTPMethod { return .get }
    var queryParameters: [String: String]? {
        return [
            "limit": String(limit),
            "offset": String(offset)
        ]
    }
}

/// 계좌 저장 요청
struct SaveAccountRequest: APIRequest {
    typealias Response = AccountDTO
    
    let account: AccountDTO
    
    var path: String { return "/api/accounts" }
    var method: HTTPMethod { return .post }
    var requestBody: RequestBody {
        return .encodable(account)
    }
}

/// 계좌 업데이트 요청
struct UpdateAccountRequest: APIRequest {
    typealias Response = AccountDTO
    
    let account: AccountDTO
    
    var path: String { return "/api/accounts/\(account.id)" }
    var method: HTTPMethod { return .put }
    var requestBody: RequestBody {
        return .encodable(account)
    }
}

/// 계좌 삭제 요청
struct DeleteAccountRequest: APIRequest {
    typealias Response = EmptyResponse
    
    let accountId: String
    
    var path: String { return "/api/accounts/\(accountId)" }
    var method: HTTPMethod { return .delete }
}

/// 거래내역 추가 요청
struct AddTransactionRequest: APIRequest {
    typealias Response = TransactionDTO
    
    let accountId: String
    let transaction: TransactionDTO
    
    var path: String { return "/api/accounts/\(accountId)/transactions" }
    var method: HTTPMethod { return .post }
    var requestBody: RequestBody {
        return .encodable(transaction)
    }
}

/// 빈 응답 타입 (HTTP 204 등의 응답을 위함)
struct EmptyResponse: Decodable {}
