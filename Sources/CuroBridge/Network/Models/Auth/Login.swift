//
//  Login.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

public struct LoginPhoneRequestBody: Encodable & Sendable {
    let phone: String
    
    public init(phone: String) {
        self.phone = phone
    }
}

public struct LoginPhoneResponseBody: Codable {
    public let otpRequestId: String
}

public struct LoginEmailRequestBody: Encodable & Sendable {
    let email: String
}
