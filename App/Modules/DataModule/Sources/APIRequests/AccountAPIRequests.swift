import Foundation
import NetworkModule
import DomainModule

/// 계좌 목록 조회 요청
public struct GetAccountsRequest: APIRequest {
    public typealias Response = [AccountDTO]
    
    public var path: String { "/accounts" }
    public var method: HTTPMethod { .get }
    public var requiresAuth: Bool { return true }
    
    public init() {}
}

/// 계좌 상세 조회 요청
public struct GetAccountRequest: APIRequest {
    public typealias Response = AccountDTO
    
    public let accountId: String
    
    public var path: String { "/accounts/\(accountId)" }
    public var method: HTTPMethod { .get }
    public var requiresAuth: Bool { return true }
    
    public init(accountId: String) {
        self.accountId = accountId
    }
}

/// 계좌 거래내역 조회 요청
public struct GetTransactionsRequest: APIRequest {
    public typealias Response = [TransactionDTO]
    
    public let accountId: String
    public let limit: Int
    public let offset: Int
    
    public var path: String { "/accounts/\(accountId)/transactions" }
    public var method: HTTPMethod { .get }
    public var requiresAuth: Bool { return true }
    
    public var queryParameters: [String : String]? {
        return [
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
    }
    
    public init(accountId: String, limit: Int = 20, offset: Int = 0) {
        self.accountId = accountId
        self.limit = limit
        self.offset = offset
    }
}

/// 계좌 잔액 업데이트 요청
public struct UpdateAccountBalanceRequest: APIRequest {
    public typealias Response = AccountDTO
    
    public let accountId: String
    public let newBalance: Decimal
    
    public var path: String { "/accounts/\(accountId)/balance" }
    public var method: HTTPMethod { .patch }
    public var requiresAuth: Bool { return true }
    
    public var requestBody: RequestBody {
        let parameters = ["balance": newBalance] as [String: Any]
        return .dictionary(parameters)
    }
    
    public init(accountId: String, newBalance: Decimal) {
        self.accountId = accountId
        self.newBalance = newBalance
    }
} 
