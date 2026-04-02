//
//  CallService.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import Foundation

public struct CreateNewCallRequest: APIRequest {
    public typealias Body = CreateNewCallRequestBody
    public typealias Response = CreateNewCallResponseBody
    
    public let path: String = "/meetings/new"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
