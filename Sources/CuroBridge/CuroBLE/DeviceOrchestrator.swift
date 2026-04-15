//
//  DeviceOrchestrator.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

final class DeviceOrchestrator {
    
    private(set) var mode: DeviceMode = .local
    
    var alpha: AlphaController?
    var stetho: StethoscopeDevice?
    
    func setMode(_ m: DeviceMode) {
        mode = m
    }
    
    func switchModule(_ module: ModuleType,
                      device: SavedDevice) async {
        
        if module == .otoscope,
           device.type == .alpha,
           device.isProvisioned != true {
            print("Provision required")
            return
        }
        
        switch module {
            
        case .stethoscope:
            await alpha?.switchTo(.thermometer)
            stetho?.start()
            
        default:
            stetho?.stop()
            await alpha?.switchTo(module)
        }
    }
}
