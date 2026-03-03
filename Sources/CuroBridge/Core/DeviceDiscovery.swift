//
//  DeviceDiscovery.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 05/04/25.
//

import Foundation
import CoreBluetooth
import ESPProvision

public class DeviceDiscovery: NSObject {
    public var onPeripheralListUpdated: (([CBPeripheral]) -> Void)?
    public var updateOtoscopeEspId: ((String) -> Void)?
    public var onWiFiList: (([ESPWifiNetwork]) -> Void)?
    public var onStepUpdate: ((CuroAlphaProvisionStep) -> Void)?
    public var onError: ((String) -> Void)?
    
    var centralManager: CBCentralManager?
    
    var servicesToScan = [CBUUID]()
    var allPeripherals: [CBPeripheral] = []
    var allWifiNetworks: [ESPWifiNetwork] = []
    
    var alphaDevice: CBPeripheral?
    var stethoscopeDevice: CBPeripheral?
    
    var alphaEspDevice: ESPDevice?
    
    var alphaStatusCharacteristic: CBCharacteristic?
    var alphaModuleCharacteristic: CBCharacteristic?
    
    // managers
    var alphaStatusManager: AlphaStatusManager?
    var alphaModuleManager: AlphaModuleManager?
    
    public func startDeviceDiscovery(_ devices: [CuroDevice]?) {
        let deviceTypes = devices ?? [CuroDevice.alpha, CuroDevice.stethoscope]
        servicesToScan.removeAll()
        if deviceTypes.contains(where: { deviceType in
            deviceType == .alpha
        }) {
            servicesToScan.append(CuroUUIDs.alphaService)
        }
        if deviceTypes.contains(where: { deviceType in
            deviceType == .stethoscope
        }) {
            servicesToScan.append(CuroUUIDs.stethoscopeService)
        }
        self.centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    public func connectDevice(_ peripheral: CBPeripheral) {
        self.centralManager?.connect(peripheral)
    }
    
    public func disconnectDevice(_ peripheral: CBPeripheral) {
        self.centralManager?.cancelPeripheralConnection(peripheral)
    }
    
    public func clearDeviceList() {
        allPeripherals.removeAll()
    }
}

extension DeviceDiscovery {
    func setAlphaStatusManager(_ manager: AlphaStatusManager) {
        self.alphaStatusManager = manager
    }
    
    func setAlphaModuleManager(_ manager: AlphaModuleManager) {
        self.alphaModuleManager = manager
    }
}

extension DeviceDiscovery {
    public func runStatusCommand(_ command: CuroAlphaCommand) {
        writeToStatusCharacteristics(command.toData())
    }
    
    public func connectEspDevice(_ deviceId: String) {
        let deviceName = "AVO-\(deviceId)"
        self.onStepUpdate?(.searchDevice)
        ESPProvisionManager.shared.searchESPDevices(devicePrefix: deviceName, transport: .ble, security: .secure) { deviceList, espError in
            if let error = espError {
                switch error {
                case .espDeviceNotFound:
                    self.onError?("Couldn't locate device.")
                default:
                    self.onError?("Error connecting to device.")
                }
            } else {
                if let espDevices = deviceList {
                    for espDevice in espDevices {
                        if espDevice.name == deviceName {
                            self.connectToAlpha(espDevice)
                        }
                    }
                }
            }
        }
    }
    
    func connectToAlpha(_ espDevice: ESPDevice) {
        espDevice.connect(delegate: self) { sessionStatus in
            switch sessionStatus {
            case .connected:
                self.onStepUpdate?(.deviceConnected)
                self.alphaEspDevice = espDevice
                self.scanAlphaWifiList()
            case .disconnected:
                self.onError?("Couldn't persist device connection")
            case .failedToConnect(let error):
                self.onError?("Error connecting to device: \(error.localizedDescription)")
            }
        }
    }
    
    func scanAlphaWifiList() {
        self.onStepUpdate?(.scanningWifi)
        self.alphaEspDevice?.scanWifiList { espWifiNetworks, wifiScanError in
            if let error = wifiScanError {
                switch error {
                case .emptyResultCount:
                    self.onError?("No WiFi networks found")
                case .emptyConfigData:
                    self.onError?("No WiFi networks found")
                case .scanRequestError(let error):
                    self.onError?("Error scanning WiFi: \(error.localizedDescription)")
                }
            } else if let espWifiNetworks = espWifiNetworks {
                self.onStepUpdate?(.wifiScanned)
                self.allWifiNetworks = espWifiNetworks
                self.onWiFiList?(espWifiNetworks)
            }
        }
    }
    
    public func provisionDevice(ssid: String, password: String = "") {
        self.onStepUpdate?(.configuringWifi)
        self.alphaEspDevice?.provision(ssid: ssid, passPhrase: password) { provisionStatus in
            switch provisionStatus {
            case .configApplied:
                self.onStepUpdate?(.wifiConfigApplied)
            case .success:
                self.onStepUpdate?(.wifiConfigured)
            case .failure(let espProvisionError):
                switch espProvisionError {
                case .sessionError:
                    self.onError?("Please retry connecting to WiFi network")
                case .configurationError(let error):
                    self.onError?("Failed to apply WiFi configuration: \(error.localizedDescription)")
                case .wifiStatusError(let error):
                    self.onError?("Failed to fetch the WiFi status of the device: \(error.localizedDescription)")
                case .wifiStatusDisconnected:
                    self.onError?("Unable to apply Wi-Fi settings")
                case .wifiStatusAuthenticationError:
                    self.onError?("WiFi credentials are incorrect")
                case .wifiStatusNetworkNotFound:
                    self.onError?("WiFi network not found")
                case .wifiStatusUnknownError:
                    self.onError?("Failed to get WiFi status of device")
                case .unknownError:
                    self.onError?("Unknown error")
                }
            }
        }
    }
    
    public func rescanWifiNetworks() {
        self.scanAlphaWifiList()
    }
}

extension DeviceDiscovery: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            self.centralManager?.scanForPeripherals(withServices: servicesToScan)
        default:
            print("Unhandled state: ", central.state)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !allPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            self.allPeripherals.append(peripheral)
            self.onPeripheralListUpdated?(self.allPeripherals)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to device: \(peripheral.name ?? "Unknown device")")
        peripheral.delegate = self
        peripheral.discoverServices(servicesToScan)
    }
}

extension DeviceDiscovery: CBPeripheralDelegate {
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        if let error = error {
            print("Error discovering services: \(error)")
            return
        }
        
        guard let services = peripheral.services else { return }
        for service in services {
            if service.uuid == CuroUUIDs.alphaService {
                alphaDevice = peripheral
            } else if service.uuid == CuroUUIDs.stethoscopeService {
                stethoscopeDevice = peripheral
            }
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let error = error {
            print("Error discovering characteristics: \(error)")
            return
        }
        guard let characteristics = service.characteristics else { return }
        for characteristic in characteristics {
            checkCharacteristics(characteristic)
        }
    }
    
    public func checkCharacteristics(_ characteristic: CBCharacteristic) {
        print("Found characteristic: \(characteristic.uuid.uuidString)")
        switch characteristic.uuid {
        case CuroUUIDs.alphaStatusCharacteristic:
            self.alphaStatusCharacteristic = characteristic
            enableNotifyForCharacteristic(peripheral: self.alphaDevice, characteristic: characteristic)
        case CuroUUIDs.alphaModuleCharacteristic:
            self.alphaModuleCharacteristic = characteristic
            enableNotifyForCharacteristic(peripheral: self.alphaDevice, characteristic: characteristic)
        default:
            print("Unknown characteristic: ", characteristic.uuid.uuidString)
        }
    }
}

extension DeviceDiscovery {
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error writing to characteristics: \(error)")
            return
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            print("Error reading value for characteristics: \(error)")
            return
        }
        
        if let value = characteristic.value {
            print("Characteristic \(characteristic.uuid.uuidString) value: \(String(decoding: value, as: UTF8.self)) hex: \(value.toHexString())")
            switch characteristic.uuid {
            case CuroUUIDs.alphaStatusCharacteristic:
                alphaStatusManager?.processPayload(value)
            case CuroUUIDs.alphaModuleCharacteristic:
                alphaModuleManager?.processPayload(value)
            default:
                print("Unhandled characteristics: \(characteristic.uuid.uuidString)")
            }
        }
    }
}

extension DeviceDiscovery {
    func enableNotifyForCharacteristic(peripheral: CBPeripheral?, characteristic: CBCharacteristic?) {
        if let peripheral = peripheral, let characteristic = characteristic {
            print("Enable notify for characteristic on \(peripheral.name ?? "Unknown device"): \(characteristic.uuid.uuidString)")
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    public func writeToModuleCharacteristics(_ data: Data) {
        if let alphaModuleCharacteristic = self.alphaModuleCharacteristic {
            writeToAlpha(data: data, characteristic: alphaModuleCharacteristic)
        }
    }
    
    public func writeToStatusCharacteristics(_ data: Data) {
        if let alphaStatusCharacteristic = self.alphaStatusCharacteristic {
            writeToAlpha(data: data, characteristic: alphaStatusCharacteristic)
        }
    }
    
    private func writeToAlpha(data: Data, characteristic: CBCharacteristic) {
        if let alphaDevice = self.alphaDevice {
            print("Writing to ALPHA: \(characteristic.uuid.uuidString)")
            alphaDevice.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
}

extension DeviceDiscovery: ESPDeviceConnectionDelegate {
    public func getProofOfPossesion(forDevice: ESPDevice, completionHandler: @escaping (String) -> Void) {
        completionHandler("abcd1234")
    }
    
    public func getUsername(forDevice: ESPDevice, completionHandler: @escaping (String?) -> Void) {
        completionHandler("puroindia")
    }
}
