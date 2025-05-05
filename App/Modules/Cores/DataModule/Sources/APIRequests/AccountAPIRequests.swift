import Foundation
import NetworkModule
import DomainModule

/// 계좌 목록 요청
public struct AccountListRequest: APIRequest {
    public typealias Response = [AccountDTO]
    
    public var path: String { return "/api/accounts" }
    public var method: HTTPMethod { return .get }
}

/// 계좌 상세 요청
public struct AccountDetailRequest: APIRequest {
    public typealias Response = AccountDTO
    
    public let accountId: String
    
    public var path: String { return "/api/accounts/\(accountId)" }
    public var method: HTTPMethod { return .get }
}

/// 계좌 거래내역 요청
public struct TransactionListRequest: APIRequest {
    public typealias Response = [TransactionDTO]
    
    public let accountId: String
    public let limit: Int
    public let offset: Int
    
    public var path: String { return "/api/accounts/\(accountId)/transactions" }
    public var method: HTTPMethod { return .get }
    public var queryParameters: [String: String]? {
        return [
            "limit": String(limit),
            "offset": String(offset)
        ]
    }
}

/// 계좌 저장 요청
public struct SaveAccountRequest: APIRequest {
    public typealias Response = AccountDTO
    
    public let account: AccountDTO
    
    public var path: String { return "/api/accounts" }
    public var method: HTTPMethod { return .post }
    public var requestBody: RequestBody {
        return .encodable(account)
    }
}

/// 계좌 업데이트 요청
public struct UpdateAccountRequest: APIRequest {
    public typealias Response = AccountDTO
    
    public let account: AccountDTO
    
    public var path: String { return "/api/accounts/\(account.id)" }
    public var method: HTTPMethod { return .put }
    public var requestBody: RequestBody {
        return .encodable(account)
    }
}

/// 계좌 삭제 요청
public struct DeleteAccountRequest: APIRequest {
    public typealias Response = EmptyResponse
    
    public let accountId: String
    
    public var path: String { return "/api/accounts/\(accountId)" }
    public var method: HTTPMethod { return .delete }
}

/// 거래내역 추가 요청
public struct AddTransactionRequest: APIRequest {
    public typealias Response = TransactionDTO
    
    public let accountId: String
    public let transaction: TransactionDTO
    
    public var path: String { return "/api/accounts/\(accountId)/transactions" }
    public var method: HTTPMethod { return .post }
    public var requestBody: RequestBody {
        return .encodable(transaction)
    }
}

/// 빈 응답 타입 (HTTP 204 등의 응답을 위함)
public struct EmptyResponse: Decodable {}
