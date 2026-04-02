//
//  DeviceDiscoveryDelegate.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 29/03/26.
//

import CoreBluetooth
import ESPProvision

public protocol DeviceDiscoveryDelegate: AnyObject {
    func onPeripheralListUpdated(_ peripherals: [CBPeripheral])
    func updateOtoscopeEspId(_ id: String)
    func onWiFiList(_ wifiList: [ESPWifiNetwork])
    func onStepUpdate(_ step: CuroAlphaProvisionStep)
    func onPeripheralUpdate(_ peripheral: CBPeripheral, update: PeripheralUpdate)
    func onStatus(_ status: CuroBridgeStatus)
    func prompt(
        message: String,
        success: () -> Void,
        failure: () -> Void
    )
    func onError(_ message: String)
}
