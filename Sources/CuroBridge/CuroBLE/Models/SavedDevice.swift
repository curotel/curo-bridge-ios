//
//  SavedDevice.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import Foundation

public enum DeviceType: String, Codable {
    case alpha
    case stethoscope
}

public struct SavedDevice: Codable, Identifiable {
    public let id: UUID
    let name: String
    let type: DeviceType
    var isProvisioned: Bool?
}
