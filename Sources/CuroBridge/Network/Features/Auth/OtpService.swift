//
//  OtpService.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 27/03/26.
//

import Foundation

public struct VerifyOtpRequest: APIRequest {
    public typealias Response = VerifyOtpResponseBody
    public typealias Body = VerifyOtpRequestBody
    
    public let path: String = "/auth/login/verify"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
