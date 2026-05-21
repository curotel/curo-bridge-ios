//
//  PhysicianProfile.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 01/05/26.
//

import Foundation

public struct PhysicianOnboardingRequestBody: Codable, Sendable {
    public var firstName: String?
    public var lastName: String?
    public var dob: String?
    public var email: String?
    public var gender: Gender?
    
    public var experience: Int8?
    public var organisation: String?
    public var specialty: String?
    
    public init() {
    }
}
