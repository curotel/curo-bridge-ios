//
//  Otp.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 26/03/26.
//

import Foundation

public struct VerifyOtpRequestBody: Encodable & Sendable {
    let otpRequestId: String
    let code: String
    
    public init(otpRequestId: String, code: String) {
        self.otpRequestId = otpRequestId
        self.code = code
    }
}

public struct VerifyOtpResponseBody: Codable {
    public let refresh: String
    public let token: String
    public let streamToken: String
    public let user: CuroUser
}

public struct ResendOtpRequestBody: Encodable & Sendable {
    let otpRequestId: String
}
