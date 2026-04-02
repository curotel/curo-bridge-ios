//
//  CuroUser.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import Foundation

public struct CuroUser: Codable, Sendable {
    public let id: String
    public let phone: String

    public let name: String?
    public let birthDate: String?
    public let createdAt: String?
    public let email: String?
    public let gender: String?
    public let profilePic: String?
}
