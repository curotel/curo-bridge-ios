//
//  StethoscopeVitalsManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 14/04/26.
//

import Foundation

public class StethoscopeVitalsManager {
    public var delegate: StethoscopeVitalsManagerDelegate?
    
    func processPayload(_ payload: Data) {
        let payloadStr = String(decoding: payload, as: UTF8.self)
        
        var voltage: Double?
        var percentage: Double?
        var charging: Bool?
        var button: Bool?
        
        let pattern = #"([VPCB]):([^VPCB]+)"#
        
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsString = payloadStr as NSString
        let matches = regex?.matches(in: payloadStr, range: NSRange(location: 0, length: nsString.length)) ?? []
        
        for match in matches {
            let key = nsString.substring(with: match.range(at: 1))
            let value = nsString.substring(with: match.range(at: 2))
            
            switch key {
            case "V":
                voltage = Double(value)
            case "P":
                percentage = Double(value)
//            case "C":
//                charging = value == "1"
//            case "B":
//                button = value == "1"
            default:
                break
            }
        }
        
        self.delegate?.onVitals(StethoscopeVitals(
            voltage: voltage,
            batteryPercentage: percentage
        ))
    }
}

public protocol StethoscopeVitalsManagerDelegate: AnyObject {
    func onVitals(_ vitals: StethoscopeVitals)
}

public struct StethoscopeVitals {
    public let voltage: Double?
    public let batteryPercentage: Double?
}
