//
//  APIRequest.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

public protocol APIRequest {
    associatedtype Response: Codable
    associatedtype Body: Encodable & Sendable
    
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
    
    var body: Body? { get }
    var headers: [String: String]? { get }
}

public struct APIResponse<T: Decodable>: Decodable {
    let message: T
    let type: String
}

public struct APIErrorResponse: Decodable {
    let message: String
    let type: String
}

public struct EmptyBody: Encodable, Sendable {}
