//
//  RefreshToken.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import Foundation

public struct RefreshTokenRequestBody: Encodable & Sendable {
    public let refresh: String

    public init(refresh: String) {
        self.refresh = refresh
    }
}

public struct RefreshTokenResponseBody: Codable {
    public let refresh: String
    public let accessToken: String
    public let streamToken: String
    public let user: CuroUser
}
