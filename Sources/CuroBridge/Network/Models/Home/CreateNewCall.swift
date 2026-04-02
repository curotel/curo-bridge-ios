//
//  CreateNewCall.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 01/04/26.
//

import Foundation

public struct CreateNewCallRequestBody: Encodable & Sendable {
    let patientPhone: String
    
    public init(patientPhone: String) {
        self.patientPhone = patientPhone
    }
}

public struct CreateNewCallResponseBody: Codable {
    public let callId: String
    public let callType: String
    public let patient: CuroUser
}
