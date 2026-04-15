//
//  ConnectionManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import CoreBluetooth

final class ConnectionManager {
    
    let bleManager: BLEManager
    
    init(bleManager: BLEManager) {
        self.bleManager = bleManager
    }
    
//    func connect(_ saved: SavedDevice) async -> CBPeripheral? {
//        for await p in bleManager.scan() {
//            let peripheral = bleManager.getPeripheralForID(p.id)
//            
//            
//            if let peripheral = peripheral, peripheral.identifier == saved.id {
//                bleManager.connect(peripheral)
//                return peripheral
//            }
//        }
//        return nil
//    }
}
