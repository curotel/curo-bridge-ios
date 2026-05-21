//
//  Specialties.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 28/04/26.
//

import Foundation

public struct FetchSpecialtiesResponseBody: Codable {
    public let specialties: [Specialty]
}

public struct Specialty: Codable, Hashable {
    public let id: String
    public let name: String
    public let designation: String
}
