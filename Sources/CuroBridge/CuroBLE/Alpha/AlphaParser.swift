//
//  AlphaParser.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

struct AlphaParser {
    
    static func parseModule(_ s: String) -> AlphaModuleEvent? {
        
        if s.contains("TEMP") { return .temperature(extractDouble(s)) }
        if s.contains("SPO2") { return .spo2(extractInt(s)) }
        if s.contains("PULSE") { return .pulse(extractInt(s)) }
        
        if s.contains("FD1") { return .fingerDetected(true) }
        if s.contains("FD0") { return .fingerDetected(false) }
        
        if s.contains("C1") { return .cuffAttached(true) }
        if s.contains("C0") { return .cuffAttached(false) }
        
        return nil
    }
    
    static func parseStatus(_ s: String) -> AlphaStatusEvent? {
        
        if s.contains("STAT0") { return .wifiStatus(0) }
        if s.contains("STAT1") { return .wifiStatus(1) }
        if s.contains("STAT2") { return .wifiStatus(2) }
        if s.contains("STAT4") { return .otoscopeReady }
        
        if s.contains("IP") { return .otoscopeIP(s) }
        
        return nil
    }
    
    private static func extractInt(_ s: String) -> Int {
        Int(s.filter { $0.isNumber }) ?? 0
    }
    
    private static func extractDouble(_ s: String) -> Double {
        Double(s.filter { $0.isNumber || $0 == "." }) ?? 0
    }
}
