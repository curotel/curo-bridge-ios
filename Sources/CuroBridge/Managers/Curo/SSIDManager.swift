//
//  SSIDManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 28/03/26.
//

import SystemConfiguration.CaptiveNetwork

final class SSIDManager {
    
    func checkIfProvisioningNeeded(_ connectedSSID: String) -> Bool {
        if connectedSSID == getSSID() {
            return false
        }
        return true
    }
    
    func getSSID() -> String? {
        guard let interfaces = CNCopySupportedInterfaces() as? [String] else {
            return nil
        }
        
        for interface in interfaces {
            if let info = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
               let ssid = info[kCNNetworkInfoKeySSID as String] as? String {
                return ssid
            }
        }
        
        return nil
    }
}
