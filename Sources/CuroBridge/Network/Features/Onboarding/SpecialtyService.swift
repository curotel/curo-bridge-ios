//
//  SpecialtyService.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 28/04/26.
//

import Foundation

public struct FetchSpecialtyRequest: APIRequest {
    public typealias Body = EmptyBody
    public typealias Response = FetchSpecialtiesResponseBody
    
    public let path: String = "/onboarding/specialties"
    public let method: HTTPMethod = .GET
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body? = nil
    
    public init() {
    }
}
