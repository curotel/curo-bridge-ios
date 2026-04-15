//
//  AlphaDevice.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import CoreBluetooth

final class AlphaDevice: NSObject, BLEDevice {
    
    let peripheral: CBPeripheral
    let bleManager: BLEManager
    
    private var moduleChar: CBCharacteristic?
    private var statusChar: CBCharacteristic?
    
    var moduleCont: AsyncStream<AlphaModuleEvent>.Continuation?
    var statusCont: AsyncStream<AlphaStatusEvent>.Continuation?
    
    init(bleManager: BLEManager, peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.bleManager = bleManager
        super.init()
        peripheral.delegate = self
    }
    
    func connect() { bleManager.connect(peripheral) }
    func disconnect() { bleManager.disconnect(peripheral) }
    
    func sendModule(_ cmd: AlphaCommand) {
        guard let c = moduleChar else { return }
        peripheral.writeValue(cmd.rawValue.data(using: .utf8)!,
                              for: c,
                              type: .withResponse)
    }
    
    func sendStatus(_ cmd: AlphaCommand) {
        guard let c = statusChar else { return }
        peripheral.writeValue(cmd.rawValue.data(using: .utf8)!,
                              for: c,
                              type: .withResponse)
    }
}

extension AlphaDevice: CBPeripheralDelegate {
    
    func peripheral(_ p: CBPeripheral, didDiscoverServices error: Error?) {
        p.services?.forEach { p.discoverCharacteristics(nil, for: $0) }
    }
    
    func peripheral(_ p: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        
        for c in service.characteristics ?? [] {
            
            if c.uuid == CBUUID(string: "MODULE_UUID") {
                moduleChar = c
                p.setNotifyValue(true, for: c)
            }
            
            if c.uuid == CBUUID(string: "STATUS_UUID") {
                statusChar = c
                p.setNotifyValue(true, for: c)
            }
        }
    }
    
    func peripheral(_ p: CBPeripheral,
                    didUpdateValueFor c: CBCharacteristic,
                    error: Error?) {
        
        guard let data = c.value,
              let s = String(data: data, encoding: .utf8) else { return }
        
        if c == moduleChar,
           let e = AlphaParser.parseModule(s) {
            moduleCont?.yield(e)
        }
        
        if c == statusChar,
           let e = AlphaParser.parseStatus(s) {
            statusCont?.yield(e)
        }
    }
}
