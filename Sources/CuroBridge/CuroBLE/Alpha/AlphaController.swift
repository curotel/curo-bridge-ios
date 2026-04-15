//
//  AlphaController.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

final class AlphaController {
    
    private let device: AlphaDevice
    private var current: ModuleType?
    
    init(device: AlphaDevice) {
        self.device = device
    }
    
    func moduleStream() -> AsyncStream<AlphaModuleEvent> {
        AsyncStream { device.moduleCont = $0 }
    }
    
    func statusStream() -> AsyncStream<AlphaStatusEvent> {
        AsyncStream { device.statusCont = $0 }
    }
    
    func switchTo(_ module: ModuleType) async {
        await stopCurrent()
        current = module
        
        switch module {
        case .thermometer:
            device.sendModule(.readTemperature)
            
        case .oximeter:
            device.sendModule(.startOximeter)
            
        case .bp:
            device.sendModule(.startBP)
            
        case .otoscope:
            device.sendModule(.startOtoscope)
            await waitForSTAT4()
            
        case .stethoscope:
            break
        }
    }
    
    private func stopCurrent() async {
        guard let m = current else { return }
        
        switch m {
        case .oximeter:
            device.sendModule(.stopOximeter)
        case .bp:
            device.sendModule(.stopBP)
        case .otoscope:
            device.sendModule(.stopOtoscope)
        default: break
        }
    }
    
    private func waitForSTAT4() async {
        for await e in statusStream() {
            if case .otoscopeReady = e { return }
        }
    }
}
