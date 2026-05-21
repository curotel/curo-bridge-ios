//
//  MeetingData.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 12/05/26.
//

import Foundation

public enum MeetingData {
    case alphaConnected
    case alphaDisconnected
    case temperature(Double)
    case oximetry(Double, Int)       // spo2, bpm
    case fingerDetected(Bool)
    case bpReading(BPReading)
    case cuffLoaded(Bool)
    case otoscope(Data)
    case ledControl(Int)
    case status(CuroAlphaStatus)
    case alphaBattery(Double)
    
    case otoscopeStarted
    case otoscopeStopped
    
    case stethoscopeConnected
    case stethoscopeDisconnected
    case stethoscopeBattery(Double)
}

public extension MeetingData {
    
    // Static cases only — dynamic (value-carrying) cases are handled in init/dataString
    @MainActor private static let lookup: [(data: MeetingData, string: String)] = [
        (.alphaConnected,          "ALPHA_CONNECTED"),
        (.alphaDisconnected,       "ALPHA_DISCONNECTED"),
        (.stethoscopeConnected,    "STETHOSCOPE_CONNECTED"),
        (.stethoscopeDisconnected, "STETHOSCOPE_DISCONNECTED"),
        (.otoscopeStarted, "OTOSCOPE_STARTED"),
        (.otoscopeStopped, "OTOSCOPE_STOPPED"),
    ]
    
    // MARK: - dataString
    
    @MainActor
    var dataString: String {
        switch self {
        case .alphaConnected, .alphaDisconnected,
                .stethoscopeConnected, .stethoscopeDisconnected,
                .otoscopeStarted, .otoscopeStopped:
            return Self.lookup.first { $0.data == self }?.string ?? ""
            
        case .temperature(let celsius):
            return String(format: "TEMP_%.1f", celsius)
            
        case .oximetry(let spo2, let bpm):
            // e.g. "OXI_98.5_72"
            return String(format: "OXI_%.1f_%d", spo2, bpm)
            
        case .fingerDetected(let detected):
            // e.g. "FINGER_1" / "FINGER_0"
            return "FINGER_\(detected ? 1 : 0)"
            
        case .bpReading(let r):
            // e.g. "BP_120_80_75"
            var string = "BP_\(r.systolic)_\(r.diastolic)_\(r.heartRate)"
            if let live = r.livePressure {
                string += "_\(live)"
            }
            return string
            
        case .cuffLoaded(let loaded):
            return "CUFF_\(loaded ? 1 : 0)"
            
        case .otoscope(let data):
            // Base64-encode the raw bytes
            return "OTO_\(data.base64EncodedString())"
            
        case .ledControl(let percent):
            let clamped = max(0, min(100, percent))
            return String(format: "LED_%03d", clamped)
            
        case .status(let status):
            return "STATUS_\(status.rawValue)"
            
        case .alphaBattery(let level):
            return String(format: "ALPHA_BATTERY_%.1f", level)
            
        case .stethoscopeBattery(let level):
            return String(format: "STETHOSCOPE_BATTERY_%.1f", level)
        }
    }
    
    // MARK: - init
    
    @MainActor
    init?(_ dataString: String) {
        // Static lookup first
        if let match = Self.lookup.first(where: { $0.string == dataString }) {
            self = match.data
            return
        }
        
        // TEMP_35.6
        if dataString.hasPrefix("TEMP_"),
           let value = Double(dataString.dropFirst("TEMP_".count)) {
            self = .temperature(value)
            return
        }
        
        // OXI_98.5_72
        if dataString.hasPrefix("OXI_") {
            let parts = dataString.dropFirst("OXI_".count).split(separator: "_")
            if parts.count == 2,
               let spo2 = Double(parts[0]),
               let bpm  = Int(parts[1]) {
                self = .oximetry(spo2, bpm)
                return
            }
        }
        
        // FINGER_1 / FINGER_0
        if dataString.hasPrefix("FINGER_"),
           let value = Int(dataString.dropFirst("FINGER_".count)) {
            self = .fingerDetected(value == 1)
            return
        }
        
        // BP_120_80_75 or BP_120_80_75_110
        if dataString.hasPrefix("BP_") {
            let parts = dataString.dropFirst("BP_".count).split(separator: "_")
            if parts.count >= 3,
               let systolic  = Int(parts[0]),
               let diastolic = Int(parts[1]),
               let heartRate = Int(parts[2]) {
                let livePressure = parts.count == 4 ? Int(parts[3]) : nil
                self = .bpReading(BPReading(systolic: systolic, diastolic: diastolic, heartRate: heartRate, livePressure: livePressure))
                return
            }
        }
        
        // CUFF_1 / CUFF_0
        if dataString.hasPrefix("CUFF_"),
           let value = Int(dataString.dropFirst("CUFF_".count)) {
            self = .cuffLoaded(value == 1)
            return
        }
        
        // OTO_<base64>
        if dataString.hasPrefix("OTO_") {
            let base64 = String(dataString.dropFirst("OTO_".count))
            if let data = Data(base64Encoded: base64) {
                self = .otoscope(data)
                return
            }
        }
        
        // LED_075
        if dataString.hasPrefix("LED_"),
           let value = Int(dataString.dropFirst("LED_".count)) {
            self = .ledControl(value)
            return
        }
        
        // STATUS_3
        if dataString.hasPrefix("STATUS_"),
           let code = Int(dataString.dropFirst("STATUS_".count)) {
            let status = CuroAlphaStatus(rawValue: code) ?? .undefined
            self = .status(status)
            return
        }
        
        // ALPHA_BATTERY_12
        if dataString.hasPrefix("ALPHA_BATTERY_"),
           let value = Double(dataString.dropFirst("ALPHA_BATTERY_".count)) {
            self = .alphaBattery(value)
            return
        }
        
        // STETHOSCOPE_BATTERY_12
        if dataString.hasPrefix("STETHOSCOPE_BATTERY_"),
           let value = Double(dataString.dropFirst("STETHOSCOPE_BATTERY_".count)) {
            self = .stethoscopeBattery(value)
            return
        }
        
        return nil
    }
}

// MARK: - Equatable

extension MeetingData: Equatable {
    public static func == (lhs: MeetingData, rhs: MeetingData) -> Bool {
        switch (lhs, rhs) {
        case (.alphaConnected, .alphaConnected),
            (.alphaDisconnected, .alphaDisconnected),
            (.stethoscopeConnected, .stethoscopeConnected),
            (.stethoscopeDisconnected, .stethoscopeDisconnected),
            (.otoscopeStarted, .otoscopeStopped):
            return true
        case (.temperature(let a),    .temperature(let b)):    return a == b
        case (.oximetry(let a, let b), .oximetry(let c, let d)): return a == c && b == d
        case (.fingerDetected(let a), .fingerDetected(let b)): return a == b
        case (.bpReading(let a),      .bpReading(let b)):      return a == b
        case (.cuffLoaded(let a),     .cuffLoaded(let b)):     return a == b
        case (.otoscope(let a),       .otoscope(let b)):       return a == b
        case (.ledControl(let a),     .ledControl(let b)):     return a == b
        case (.status(let a), .status(let b)): return a == b
        case (.alphaBattery(let a),    .alphaBattery(let b)):    return a == b
        case (.stethoscopeBattery(let a),    .stethoscopeBattery(let b)):    return a == b
        default: return false
        }
    }
}
