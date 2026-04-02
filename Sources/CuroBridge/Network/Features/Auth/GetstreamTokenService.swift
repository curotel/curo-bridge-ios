//
//  GetS.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import Foundation

public struct GetstreamTokenRequest: APIRequest {
    public typealias Response = GetstreamTokenResponseBody
    public typealias Body = EmptyBody
    
    public let path: String = "/auth/getstream"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body? = nil
}
