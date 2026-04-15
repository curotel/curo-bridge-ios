//
//  StethoscopeDevice.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import CoreBluetooth

final class StethoscopeDevice: NSObject, BLEDevice {
    
    let peripheral: CBPeripheral
    let bleManager: BLEManager
    
    private var dataChar: CBCharacteristic?
    private var commandChar: CBCharacteristic?
    
    var audioCont: AsyncStream<Data>.Continuation?
    
    init(bleManager: BLEManager, peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.bleManager = bleManager
        super.init()
        peripheral.delegate = self
    }
    
    func connect() { bleManager.connect(peripheral) }
    func disconnect() { bleManager.disconnect(peripheral) }
    
    func start() { send("$STRT1!") }
    func stop() { send("$STOP!") }
    
    private func send(_ s: String) {
        guard let c = commandChar else { return }
        peripheral.writeValue(s.data(using: .utf8)!,
                              for: c,
                              type: .withResponse)
    }
}

extension StethoscopeDevice: CBPeripheralDelegate {
    
    func peripheral(_ p: CBPeripheral,
                    didUpdateValueFor c: CBCharacteristic,
                    error: Error?) {
        
        if c == dataChar {
            audioCont?.yield(c.value!)
        }
    }
}
