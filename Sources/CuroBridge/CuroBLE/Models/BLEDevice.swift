//
//  BLEDevice.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

import CoreBluetooth

protocol BLEDevice: AnyObject {
    var peripheral: CBPeripheral { get }
    func connect()
    func disconnect()
}

public struct DiscoveredDevice: Sendable {
    public let id: UUID
    public let name: String?
    public let rssi: Int?
}
