import Foundation
import Combine

public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func upload<T: Decodable>(to endpoint: APIEndpoint, data: Data, mimeType: String) async throws -> T
}

public class NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let configuration: APIConfiguration
    private let plugins: [NetworkPlugin]
    
    public init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        configuration: APIConfiguration,
        plugins: [NetworkPlugin] = []
    ) {
        self.session = session
        self.decoder = decoder
        self.configuration = configuration
        self.plugins = plugins
        
        // JSON 디코더 설정
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        guard var urlRequest = try? endpoint.asURLRequest(baseURL: configuration.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        // 공통 헤더 추가
        configuration.headers.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        // 요청 전 플러그인 실행
        try await plugins.asyncForEach { plugin in
            try await plugin.prepare(&urlRequest)
        }
        
        // API 요청 실행
        let (data, response) = try await session.data(for: urlRequest)
        
        // 응답 확인
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 응답 후 플러그인 실행
        try await plugins.asyncForEach { plugin in
            try await plugin.process(urlRequest, httpResponse, data)
        }
        
        // 상태 코드 확인
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: data)
        }
        
        // 응답 데이터 디코딩
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    public func upload<T: Decodable>(to endpoint: APIEndpoint, data: Data, mimeType: String) async throws -> T {
        guard var urlRequest = try? endpoint.asURLRequest(baseURL: configuration.baseURL) else {
            throw NetworkError.invalidURL
        }
        
        // 업로드를 위한 설정
        urlRequest.httpMethod = "POST"
        urlRequest.addValue(mimeType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = data
        
        // 요청 전 플러그인 실행
        try await plugins.asyncForEach { plugin in
            try await plugin.prepare(&urlRequest)
        }
        
        // 업로드 요청 실행
        let (responseData, response) = try await session.upload(for: urlRequest, from: data)
        
        // 응답 확인
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 응답 후 플러그인 실행
        try await plugins.asyncForEach { plugin in
            try await plugin.process(urlRequest, httpResponse, responseData)
        }
        
        // 상태 코드 확인
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, data: responseData)
        }
        
        // 응답 데이터 디코딩
        do {
            return try decoder.decode(T.self, from: responseData)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

// 배열에 대한 비동기 forEach 확장
extension Array {
    func asyncForEach(
        _ operation: @escaping (Element) async throws -> Void
    ) async throws {
        for element in self {
            try await operation(element)
        }
    }
} 