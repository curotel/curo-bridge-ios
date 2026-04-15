//
//  BLEManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import CoreBluetooth

final public class BLEManager: NSObject {
    
    private var central: CBCentralManager!
    public var discoveredPeripherals: [UUID: CBPeripheral] = [:]
    private var discovered: [DiscoveredDevice] = []
    
    private var scanContinuation: AsyncStream<DiscoveredDevice>.Continuation?
    private var shouldScanWhenPoweredOn = false
    
    override public init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }
    
//    public func scan(_ types: [CuroDevice]) -> AsyncStream<DiscoveredDevice> {
//        var servicesToScan: [CBUUID] = []
//        
//        if types.contains(.alpha) {
//            servicesToScan.append(CuroUUIDs.alphaService)
//        }
//        if types.contains(.stethoscope) {
//            servicesToScan.append(CuroUUIDs.stethoscopeService)
//        }
//        AsyncStream { continuation in
//            self.scanContinuation = continuation
//            
//            if self.central.state == .poweredOn {
//                self.startScan(servicesToScan)
//            } else {
//                self.shouldScanWhenPoweredOn = true
//            }
//        }
//    }
    
    private func startScan(_ servicesToScan: [CBUUID]?) {
        central.scanForPeripherals(withServices: servicesToScan)
    }
    
    public func connect(_ p: CBPeripheral) {
        central.connect(p)
    }
    
    public func disconnect(_ p: CBPeripheral) {
        central.cancelPeripheralConnection(p)
    }
    
    public func getPeripheralForID(_ id: UUID) -> CBPeripheral? {
        return discoveredPeripherals[id]
    }
}

extension BLEManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn && shouldScanWhenPoweredOn {
            shouldScanWhenPoweredOn = false
//            startScan()
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        self.discoveredPeripherals[peripheral.identifier] = peripheral
        
        scanContinuation?.yield(
            DiscoveredDevice(
                id: peripheral.identifier,
                name: peripheral.name,
                rssi: RSSI.intValue
            )
        )
    }
}
