//
//  SetDeviceTokenService.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 03/04/26.
//

import Foundation

public struct SetDeviceTokenRequest: APIRequest {
    public typealias Body = SetDeviceTokenRequestBody
    public typealias Response = String
    
    public let path: String = "/auth/tokens"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
