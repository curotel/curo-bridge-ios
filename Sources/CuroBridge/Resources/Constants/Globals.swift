//
//  Globals.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 17/03/26.
//

import Foundation

public enum Gender: Int, Codable, Sendable {
    case invalid = 0
    case male = 1
    case female = 2
    case other = 3
    
    public var id: Int { rawValue }
}
