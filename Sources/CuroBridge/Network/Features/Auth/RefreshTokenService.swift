//
//  RefreshToken.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import Foundation

public struct RefreshTokenRequest: APIRequest {
    public typealias Response = RefreshTokenResponseBody
    public typealias Body = RefreshTokenRequestBody
    
    public let path: String = "/auth/refresh"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
