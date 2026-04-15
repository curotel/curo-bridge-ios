//
//  AlphaCommands.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import Foundation

public enum AlphaCommand: String {
    // module
    case readTemperature = "$T1!"
    
    case startOximeter = "$S1!"
    case stopOximeter = "$S0!"
    
    case startBP = "$B1!"
    case stopBP = "$B0!"
    
    case startOtoscope = "$V1!"
    case stopOtoscope = "$V0!"
    
    case deviceHealth = "$P1!"
    
    // status
    case getESPID = "$BLID!"
    case getSSID = "$SSID!"
    case resetESP = "$HRST!"
    case requestIP = "$IPAD!"
}


public extension AlphaCommand {
    func toData() -> Data {
        self.rawValue.data(using: .utf8)!
    }
}
