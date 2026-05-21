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
    public var discoveryType: DiscoveryType?
    weak public var delegate: DeviceDiscoveryDelegate?
    
    var centralManager: CBCentralManager?
    
    var servicesToScan = [CBUUID]()
    var allPeripherals: [CBPeripheral] = []
    var allWifiNetworks: [ESPWifiNetwork] = []
    
    // device references
    @Published public var alphaDevice: CBPeripheral?
    @Published public var stethoscopeDevice: CBPeripheral?
    var alphaEspDevice: ESPDevice?
    
    // alpha characteristics
    var alphaStatusCharacteristic: CBCharacteristic?
    var alphaModuleCharacteristic: CBCharacteristic?
    
    // alpha managers
    var alphaStatusManager = AlphaStatusManager()
    var alphaModuleManager = AlphaModuleManager()
    
    // alpha statuses
    var alphaDeviceStatus: CuroAlphaStatus = .undefined
    
    
    /// Invalidates pending SSID retries when incremented (disconnect or leaving connected state).
    private var ssidRequestSessionID: Int = 0
    /// Ensures `$BLID!` / ESP search runs at most once per Alpha BLE connection when status is `.noConfiguration`.
    private var didBeginEspProvisioningFromNoConfiguration = false
    
    public func setDiscoveryType(_ discoveryType: DiscoveryType) {
        self.discoveryType = discoveryType
    }
    
    public func setStatusManagerDelegate(_ delegate: AlphaStatusManagerDelegate?) {
        alphaStatusManager.delegate = delegate
    }
    
    public func setModuleManagerDelegate(_ delegate: AlphaModuleManagerDelegate?) {
        alphaModuleManager.delegate = delegate
    }
    
    /// Delivers UI-model updates on the main queue (SwiftUI / `@Published` require main-thread updates).
    private func dispatchToMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    public func startDeviceDiscovery(_ devices: [CuroDeviceType]?) {
        let deviceTypes = devices ?? [CuroDeviceType.alpha, CuroDeviceType.stethoscope]
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
        
//        self.alphaStatusManager.onDeviceStatus = { [weak self] status in
//            self?.alphaDeviceStatus = status
//            
//            guard let self else { return }
//            switch status {
//            case .noConfiguration:
//                if self.alphaDeviceStatus == .connected {
//                    self.invalidateSsidRequestSchedule()
//                }
//                guard !self.didBeginEspProvisioningFromNoConfiguration else { break }
//                self.didBeginEspProvisioningFromNoConfiguration = true
//                self.runStatusCommand(.requestDeviceId)
//            case .notConnected:
//                // TODO
//                print("The device is connected to a WiFI but is not in range.")
//            case .connected:
//                if self.alphaDeviceStatus != .connected {
//                    self.requestAlphaSSID()
//                }
//                if self.discoveryType == .local {
//                    delegate?.onStatus(.deviceConnected)
//                }
//            case .otoscopeOn:
//                // TODO
//                print("Otoscope is running")
//            default:
//                if self.alphaDeviceStatus == .connected {
//                    self.invalidateSsidRequestSchedule()
//                }
//                print("Alpha status:", status)
//            }
//        }
//        
//        self.alphaStatusManager.onSsidReceived = { [weak self] ssid in
//            guard let self else { return }
//            if self.ssidManager.checkIfProvisioningNeeded(ssid) {
//                self.runStatusCommand(.resetDevice)
//            }
//        }
//        
//        self.alphaStatusManager.onCameraIdReceived = { [weak self] cameraId in
//            guard let self else { return }
//            self.connectEspDevice(cameraId)
//        }
    }
    
    public func connectDevice(_ peripheral: CBPeripheral) {
        alphaDeviceStatus = .undefined
        if discoveryType == .setup {
            didBeginEspProvisioningFromNoConfiguration = false
        }
        self.centralManager?.connect(peripheral)
    }
    
    public func disconnectDevice(_ peripheral: CBPeripheral) {
        invalidateSsidRequestSchedule()
        alphaDeviceStatus = .undefined
        didBeginEspProvisioningFromNoConfiguration = false
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
    
    private func requestAlphaSSID() {
        ssidRequestSessionID &+= 1
        let session = ssidRequestSessionID
        let send: () -> Void = { [weak self] in
            guard let self, session == self.ssidRequestSessionID else { return }
            self.runAlphaStatusCommand(.getSSID)
        }
        DispatchQueue.main.async(execute: send)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: send)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: send)
    }
    
    private func invalidateSsidRequestSchedule() {
        ssidRequestSessionID &+= 1
    }
    
    public func runAlphaStatusCommand(_ command: AlphaCommand) {
        self.writeToStatusCharacteristics(command.toData())
    }
    
    public func connectEspDevice(_ deviceId: String) {
        let deviceName = "\(curoEspPrefix)\(deviceId)"
        print("Connecting to ", deviceName)
        dispatchToMain { self.delegate?.onStepUpdate(.searchDevice) }
        ESPProvisionManager.shared.searchESPDevices(devicePrefix: deviceName, transport: .ble, security: .secure) { deviceList, espError in
            self.dispatchToMain {
                if let error = espError {
                    switch error {
                    case .espDeviceNotFound:
                        self.delegate?.onError("Couldn't locate device.")
                    default:
                        self.delegate?.onError("Error connecting to device.")
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
    }
    
    func connectToAlpha(_ espDevice: ESPDevice) {
        print("connectToAlpha", espDevice)
        espDevice.connect(delegate: self) { sessionStatus in
            self.dispatchToMain {
                switch sessionStatus {
                case .connected:
                    self.delegate?.onStepUpdate(.deviceConnected)
                    self.alphaEspDevice = espDevice
                    self.scanAlphaWifiList()
                case .disconnected:
                    self.delegate?.onError("Couldn't persist device connection")
                case .failedToConnect(let error):
                    self.delegate?.onError("Error connecting to device: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scanAlphaWifiList() {
        print("scanAlphaWifiList")
        dispatchToMain { self.delegate?.onStepUpdate(.scanningWifi) }
        self.alphaEspDevice?.scanWifiList { espWifiNetworks, wifiScanError in
            self.dispatchToMain {
                if let error = wifiScanError {
                    switch error {
                    case .emptyResultCount:
                        self.delegate?.onError("No WiFi networks found")
                    case .emptyConfigData:
                        self.delegate?.onError("No WiFi networks found")
                    case .scanRequestError(let error):
                        self.delegate?.onError("Error scanning WiFi: \(error.localizedDescription)")
                    }
                } else if let espWifiNetworks = espWifiNetworks {
                    self.delegate?.onWiFiList(espWifiNetworks)
                    self.delegate?.onStepUpdate(.wifiScanned)
                    self.allWifiNetworks = espWifiNetworks
                }
            }
        }
    }
    
    public func provisionDevice(ssid: String, password: String = "") {
        dispatchToMain { self.delegate?.onStepUpdate(.configuringWifi) }
        self.alphaEspDevice?.provision(ssid: ssid, passPhrase: password) { provisionStatus in
            self.dispatchToMain {
                switch provisionStatus {
                case .configApplied:
                    self.delegate?.onStepUpdate(.wifiConfigApplied)
                case .success:
                    self.delegate?.onStepUpdate(.wifiConfigured)
                case .failure(let espProvisionError):
                    switch espProvisionError {
                    case .sessionError:
                        self.delegate?.onError("Please retry connecting to WiFi network")
                    case .configurationError(let error):
                        self.delegate?.onError("Failed to apply WiFi configuration: \(error.localizedDescription)")
                    case .wifiStatusError(let error):
                        self.delegate?.onError("Failed to fetch the WiFi status of the device: \(error.localizedDescription)")
                    case .wifiStatusDisconnected:
                        self.delegate?.onError("Unable to apply Wi-Fi settings")
                    case .wifiStatusAuthenticationError:
                        self.delegate?.onError("WiFi credentials are incorrect")
                    case .wifiStatusNetworkNotFound:
                        self.delegate?.onError("WiFi network not found")
                    case .wifiStatusUnknownError:
                        self.delegate?.onError("Failed to get WiFi status of device")
                    default:
                        self.delegate?.onError("Unknown error")
                    }
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
        dispatchToMain {
            if !self.allPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
                self.allPeripherals.append(peripheral)
                self.delegate?.onPeripheralListUpdated(self.allPeripherals)
            }
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to device: \(peripheral.name ?? "Unknown device")")
        peripheral.delegate = self
        peripheral.discoverServices(servicesToScan)
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        invalidateSsidRequestSchedule()
        alphaDeviceStatus = .undefined
        didBeginEspProvisioningFromNoConfiguration = false
        if peripheral == alphaDevice {
            alphaStatusCharacteristic = nil
            alphaModuleCharacteristic = nil
            alphaDevice = nil
            delegate?.onPeripheralUpdate(peripheral, update: .alphaDisconnected)
        } else if peripheral == stethoscopeDevice {
            stethoscopeDevice = nil
            delegate?.onPeripheralUpdate(peripheral, update: .stethoscopeDisconnected)
        }
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
                delegate?.onPeripheralUpdate(peripheral, update: .alphaConnected)
            } else if service.uuid == CuroUUIDs.stethoscopeService {
                stethoscopeDevice = peripheral
                delegate?.onPeripheralUpdate(peripheral, update: .stethoscopeConnected)
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
                alphaStatusManager.processPayload(peripheral: peripheral, payload: value)
            case CuroUUIDs.alphaModuleCharacteristic:
                alphaModuleManager.processPayload(value)
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
        guard let alphaDevice = self.alphaDevice else { return }
        let props = characteristic.properties
        let payloadDescription = String(decoding: data, as: UTF8.self)
        if props.contains(.write) {
            print("Writing to ALPHA (with response): \(characteristic.uuid.uuidString) \(payloadDescription)")
            alphaDevice.writeValue(data, for: characteristic, type: .withResponse)
        } else if props.contains(.writeWithoutResponse) {
            print("Writing to ALPHA (without response): \(characteristic.uuid.uuidString) \(payloadDescription)")
            alphaDevice.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            print("Characteristic \(characteristic.uuid.uuidString) does not support write; cannot send: \(payloadDescription)")
        }
    }
}

extension DeviceDiscovery: ESPDeviceConnectionDelegate {
    public func getProofOfPossesion(forDevice: ESPDevice, completionHandler: @escaping (String) -> Void) {
        if let espDeviceId = self.alphaStatusManager.espDeviceId, espDeviceId.count > 6 {
            completionHandler("P\(String(espDeviceId.suffix(6)))")
        }
    }
    
    public func getUsername(forDevice: ESPDevice, completionHandler: @escaping (String?) -> Void) {
        completionHandler("curotel")
    }
}

extension DeviceDiscovery {
    public func runAlphaModuleCommands(_ command: AlphaCommand) {
        self.writeToModuleCharacteristics(command.toData())
    }
}
