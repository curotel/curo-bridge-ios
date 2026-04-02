//
//  Login.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 27/03/26.
//

import Foundation

public struct LoginWithPhoneRequest: APIRequest {
    public typealias Response = LoginPhoneResponseBody
    public typealias Body = LoginPhoneRequestBody
    
    public let path: String = "/auth/login"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
