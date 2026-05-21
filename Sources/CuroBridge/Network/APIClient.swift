//
//  APIClient.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

public enum HTTPMethod: String, Sendable {
    case GET, POST, PUT, PATCH, DELETE
}

@MainActor
public final class APIClient {
    public static let shared = APIClient()
    private init() {}
    
    private let baseURL = API_ENDPOINT
    
    // MARK: - Public Request
    
    public func send<T: APIRequest>(
        _ request: T,
        isRetry: Bool = false,
        logoutIfUnauthorized: Bool = true
    ) async throws -> T.Response {
        
        let urlRequest = try await buildRequest(from: request)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            return try await handleResponse(data: data, response: response, logoutIfUnauthorized: logoutIfUnauthorized)
            
        } catch {
            if let networkError = error as? NetworkError,
               case .serverMessage(let string) = networkError {
                print("Server error: ", string)
            }
            
            // Handle 401 → try refresh
            if let networkError = error as? NetworkError,
               case .unauthorized = networkError,
               !isRetry {
                
                do {
                    let newToken = try await AuthManager.shared.refreshTokenIfNeeded()
                    
                    var retryRequest = urlRequest
                    retryRequest.setValue("JWT \(newToken)", forHTTPHeaderField: "Authorization")
                    
                    let (data, response) = try await URLSession.shared.data(for: retryRequest)
                    
                    return try await handleResponse(data: data, response: response, logoutIfUnauthorized: logoutIfUnauthorized)
                    
                } catch {
                    if logoutIfUnauthorized {
                        await AuthManager.shared.handleLogout()
                    }
                    throw NetworkError.unauthorized
                }
            }
            
            throw error
        }
    }
    
    // MARK: - Build Request
    
    private func buildRequest<T: APIRequest>(from request: T) async throws -> URLRequest {
        
        guard let base = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        guard var components = URLComponents(
            url: base.appendingPathComponent(request.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = request.queryItems
        
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // Body
        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        // JWT
        if let token = try await AuthManager.shared.getValidAccessToken() {
            urlRequest.setValue("JWT \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Custom headers
        request.headers?.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return urlRequest
    }
    
    // MARK: - Handle Response
    
    private func handleResponse<T: Decodable>(
        data: Data,
        response: URLResponse,
        logoutIfUnauthorized: Bool = true
    ) async throws -> T {
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        
        switch http.statusCode {
            
        case 200...299:
            do {
                let decoded = try decoder.decode(APIResponse<T>.self, from: data)
                return decoded.message
            } catch {
                print(error)
                throw NetworkError.invalidData
            }
            
        case 401:
            if logoutIfUnauthorized {
                await AuthManager.shared.handleLogout()
            }
            throw NetworkError.unauthorized
            
        default:
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw NetworkError.serverMessage(errorResponse.message)
            }
            
            // Fallback: raw response
            let rawMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Unhandled error response:", rawMessage)
            
            throw NetworkError.serverError(http.statusCode)
        }
    }
}
