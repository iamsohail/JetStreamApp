import Foundation
import UIKit

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let config: AppConfig
    private let keychainManager: KeychainManager

    init(
        session: URLSession = .shared,
        keychainManager: KeychainManager = KeychainManager()
    ) {
        self.session = session
        self.keychainManager = keychainManager
        self.config = AppConfig.shared

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(for: endpoint)
        logRequest(request)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        logResponse(response, data: data)
        return try decodeResponse(data)
    }

    func request(_ endpoint: APIEndpoint) async throws {
        let request = try buildRequest(for: endpoint)
        logRequest(request)
        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)
        logResponse(response, data: data)
    }

    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard var components = URLComponents(url: config.apiBaseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL
        }

        if let queryParams = endpoint.queryParameters, !queryParams.isEmpty {
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.timeoutInterval = config.networkTimeout
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(config.appVersion, forHTTPHeaderField: "X-App-Version")

        if endpoint.requiresAuth, let token = keychainManager.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }

        return request
    }

    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299: return
        case 401: throw NetworkError.unauthorized
        case 403: throw NetworkError.forbidden
        case 404: throw NetworkError.notFound
        case 422:
            let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.validationError(errorResponse?.error.message ?? "Validation failed")
        case 429: throw NetworkError.rateLimited
        case 500...599: throw NetworkError.serverError(httpResponse.statusCode)
        default: throw NetworkError.unknown(httpResponse.statusCode)
        }
    }

    private func decodeResponse<T: Decodable>(_ data: Data) throws -> T {
        do {
            let wrappedResponse = try decoder.decode(APIResponse<T>.self, from: data)
            return wrappedResponse.data
        } catch {
            return try decoder.decode(T.self, from: data)
        }
    }

    private func logRequest(_ request: URLRequest) {
        guard config.isLoggingEnabled else { return }
        print("------ API Request ------")
        print("URL: \(request.url?.absoluteString ?? "N/A")")
        print("Method: \(request.httpMethod ?? "N/A")")
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        print("-------------------------")
    }

    private func logResponse(_ response: URLResponse, data: Data) {
        guard config.isLoggingEnabled else { return }
        print("------ API Response ------")
        if let httpResponse = response as? HTTPURLResponse {
            print("Status: \(httpResponse.statusCode)")
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("Body: \(responseString.prefix(1000))")
        }
        print("--------------------------")
    }
}

// MARK: - Response Types

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let meta: APIMeta?
}

struct APIMeta: Decodable {
    let page: Int?
    let limit: Int?
    let total: Int?
}

struct APIErrorResponse: Decodable {
    let success: Bool
    let error: APIError
}

struct APIError: Decodable {
    let code: String
    let message: String
}

// MARK: - Network Error

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case validationError(String)
    case rateLimited
    case serverError(Int)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .unauthorized: return "Session expired. Please sign in again."
        case .forbidden: return "Access denied"
        case .notFound: return "Not found"
        case .validationError(let msg): return msg
        case .rateLimited: return "Too many requests. Please try again later."
        case .serverError(let code): return "Server error (\(code))"
        case .unknown(let code): return "Unexpected error (\(code))"
        }
    }
}

// MARK: - HTTP Method

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
