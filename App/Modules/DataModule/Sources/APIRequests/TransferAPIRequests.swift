import Foundation
import NetworkModule

/// 송금 요청
struct TransferRequest: APIRequest {
    typealias Response = TransferResponseDTO
    
    let fromAccountId: String
    let toAccountNumber: String
    let amount: Decimal
    let description: String?
    
    var path: String { "/transfer" }
    var method: HTTPMethod { .post }
    var requestBody: RequestBody {
        var parameters: [String: Any] = [
            "fromAccountId": fromAccountId,
            "toAccountNumber": toAccountNumber,
            "amount": amount
        ]
        
        if let description = description {
            parameters["description"] = description
        }
        
        return .dictionary(parameters)
    }
}

/// 송금 내역 요청
struct TransferHistoryRequest: APIRequest {
    typealias Response = [TransferHistoryDTO]
    
    let accountId: String
    let limit: Int
    let offset: Int
    
    var path: String { "/accounts/\(accountId)/transfers" }
    var method: HTTPMethod { .get }
    var queryParameters: [String: String]? {
        [
            "limit": "\(limit)",
            "offset": "\(offset)"
        ]
    }
}

/// 자주 쓰는 계좌 조회 요청
struct FrequentAccountsRequest: APIRequest {
    typealias Response = [FrequentAccountDTO]
    
    var path: String { "/frequent-accounts" }
    var method: HTTPMethod { .get }
}

/// 자주 쓰는 계좌 추가 요청
struct AddFrequentAccountRequest: APIRequest {
    typealias Response = FrequentAccountDTO
    
    let bankName: String
    let accountNumber: String
    let holderName: String
    let nickname: String?
    
    var path: String { "/frequent-accounts" }
    var method: HTTPMethod { .post }
    var requestBody: RequestBody {
        var parameters: [String: Any] = [
            "bankName": bankName,
            "accountNumber": accountNumber,
            "holderName": holderName
        ]
        
        if let nickname = nickname {
            parameters["nickname"] = nickname
        }
        
        return .dictionary(parameters)
    }
}

/// 자주 쓰는 계좌 삭제 요청
struct RemoveFrequentAccountRequest: APIRequest {
    typealias Response = EmptyResponse
    
    let id: String
    
    var path: String { "/frequent-accounts/\(id)" }
    var method: HTTPMethod { .delete }
}

/// 빈 응답 타입
struct EmptyResponse: Decodable {} 
