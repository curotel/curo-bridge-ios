//
//  DeviceRegistry.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import Foundation

final class DeviceRegistry {
    
    private let key = "devices"
    
    private(set) var devices: [SavedDevice] = []
    
    func load() {
        guard let d = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([SavedDevice].self, from: d)
        else { return }
        
        devices = decoded
    }
    
    func add(_ d: SavedDevice) {
        devices.append(d)
        save()
    }
    
    private func save() {
        let d = try? JSONEncoder().encode(devices)
        UserDefaults.standard.set(d, forKey: key)
    }
}
