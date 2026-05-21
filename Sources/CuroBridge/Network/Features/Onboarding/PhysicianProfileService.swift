//
//  DoctorProfile.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 28/04/26.
//

import Foundation

public struct UpdatePhysicianProfileRequest: APIRequest {
    public typealias Body = PhysicianOnboardingRequestBody
    public typealias Response = String
    
    public let path: String = "/onboarding/physician"
    public let method: HTTPMethod = .POST
    public let queryItems: [URLQueryItem]? = nil
    public let headers: [String: String]? = nil
    
    public let body: Body?
    
    public init(request: Body) {
        self.body = request
    }
}
