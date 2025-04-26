import Foundation
import NetworkModule

/// 송금 요청
struct TransferRequest: APIRequest {
    typealias Response = TransferResponseDTO
    
    let fromAccountId: String
    let toAccountNumber: String
    let amount: Decimal
    let description: String?
    
    var path: String { return "/api/transfer" }
    var method: HTTPMethod { return .post }
    var requestBody: RequestBody {
        var body: [String: Any] = [
            "fromAccountId": fromAccountId,
            "toAccountNumber": toAccountNumber,
            "amount": amount
        ]
        
        if let description = description {
            body["description"] = description
        }
        
        return .dictionary(body)
    }
}

/// 송금 내역 요청
struct TransferHistoryRequest: APIRequest {
    typealias Response = [TransferHistoryDTO]
    
    let accountId: String
    let limit: Int
    let offset: Int
    
    var path: String { return "/api/transfers/\(accountId)" }
    var method: HTTPMethod { return .get }
    var queryParameters: [String: String]? {
        return [
            "limit": String(limit),
            "offset": String(offset)
        ]
    }
}

/// 자주 쓰는 계좌 목록 요청
struct FrequentAccountsRequest: APIRequest {
    typealias Response = [FrequentAccountDTO]
    
    var path: String { return "/api/frequent-accounts" }
    var method: HTTPMethod { return .get }
}

/// 자주 쓰는 계좌 추가 요청
struct AddFrequentAccountRequest: APIRequest {
    typealias Response = FrequentAccountDTO
    
    let bankName: String
    let accountNumber: String
    let holderName: String
    let nickname: String?
    
    var path: String { return "/api/frequent-accounts" }
    var method: HTTPMethod { return .post }
    var requestBody: RequestBody {
        var body: [String: Any] = [
            "bankName": bankName,
            "accountNumber": accountNumber,
            "holderName": holderName
        ]
        
        if let nickname = nickname {
            body["nickname"] = nickname
        }
        
        return .dictionary(body)
    }
}

/// 자주 쓰는 계좌 삭제 요청
struct RemoveFrequentAccountRequest: APIRequest {
    typealias Response = EmptyResponse
    
    let id: String
    
    var path: String { return "/api/frequent-accounts/\(id)" }
    var method: HTTPMethod { return .delete }
}

/// 자주 쓰는 계좌 업데이트 요청
struct UpdateFrequentAccountRequest: APIRequest {
    typealias Response = FrequentAccountDTO
    
    let id: String
    let bankName: String?
    let accountNumber: String?
    let holderName: String?
    let nickname: String?
    
    var path: String { return "/api/frequent-accounts/\(id)" }
    var method: HTTPMethod { return .put }
    var requestBody: RequestBody {
        var body: [String: Any] = [:]
        
        if let bankName = bankName {
            body["bankName"] = bankName
        }
        
        if let accountNumber = accountNumber {
            body["accountNumber"] = accountNumber
        }
        
        if let holderName = holderName {
            body["holderName"] = holderName
        }
        
        // nickname이 nil이면 삭제된 것으로 처리
        body["nickname"] = nickname
        
        return .dictionary(body)
    }
}

/// 계좌 확인 요청
struct VerifyAccountRequest: APIRequest {
    typealias Response = VerifyAccountResponseDTO
    
    let accountNumber: String
    let bankCode: String?
    
    var path: String { return "/api/accounts/verify" }
    var method: HTTPMethod { return .get }
    var queryParameters: [String: String]? {
        var params: [String: String] = ["accountNumber": accountNumber]
        if let bankCode = bankCode {
            params["bankCode"] = bankCode
        }
        return params
    }
}
