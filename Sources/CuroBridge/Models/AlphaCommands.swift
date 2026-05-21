//
//  AlphaCommands.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import Foundation

public enum AlphaCommand {
    // Module
    case readTemperature
    case startOximeter
    case stopOximeter
    case startBP
    case stopBP
    case startOtoscope
    case stopOtoscope
    case deviceHealth
    case changeLEDIntensity(Int)

    // Status
    case getESPID
    case getSSID
    case resetESP
    case requestIP
}

public extension AlphaCommand {

    var rawValue: String {
        switch self {
        case .readTemperature:           return "$T1!"
        case .startOximeter:             return "$S1!"
        case .stopOximeter:              return "$S0!"
        case .startBP:                   return "$B1!"
        case .stopBP:                    return "$B0!"
        case .startOtoscope:             return "$V1!"
        case .stopOtoscope:              return "$V0!"
        case .deviceHealth:              return "$P1!"
        case .getESPID:                  return "$BLID!"
        case .getSSID:                   return "$SSID!"
        case .resetESP:                  return "$HRST!"
        case .requestIP:                 return "$IPAD!"
        case .changeLEDIntensity(let pct):
            let clamped = max(0, min(100, pct))
            return String(format: "$L%03d!", clamped)
        }
    }

    func toData() -> Data {
        rawValue.data(using: .utf8)!
    }
}
