//
//  CuroProvisioningManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 12/04/26.
//

import CoreBluetooth
import ESPProvision

public final class CuroProvisioningManager {
    private let provisionManager = ESPProvisionManager.shared
    private var delegate: CuroProvisioningManagerDelegate? = nil
    private var alphaEspDevice: ESPDevice? = nil
    var allWifiNetworks: [ESPWifiNetwork] = []
    private var espIdToConnect: String? = nil
    
    public init() {
    }
    
    private func dispatchToMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    public func setDelegate(_ delegate: CuroProvisioningManagerDelegate) {
        self.delegate = delegate
    }
    
    public func startProvisioning(_ espId: String) {
        espIdToConnect = espId
        let deviceName = "\(curoEspPrefix)\(espId)"
        print("Connecting to ", deviceName)
        dispatchToMain { self.delegate?.onStepUpdate(.searchDevice) }
        provisionManager.searchESPDevices(devicePrefix: deviceName, transport: .ble, security: .secure) { deviceList, espError in
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
            print("sessionStatus", sessionStatus)
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
    
    public func scanAlphaWifiList() {
        print("scanAlphaWifiList")
        self.delegate?.onStepUpdate(.scanningWifi)
        self.alphaEspDevice?.scanWifiList { [self] espWifiNetworks, wifiScanError in
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
    
    public func getProvisionStepText(_ step: CuroAlphaProvisionStep) -> String {
        switch step {
        case .idle:
            "Preparing device setup..."
            
        case .requestedDeviceId:
            "Requesting device information..."
            
        case .receivedDeviceId:
            "Device identified. Preparing connection..."
            
        case .requestedSsid:
            "Requesting Wi-Fi details..."
            
        case .receivedSsid:
            "Wi-Fi details received."
            
        case .searchDevice:
            "Searching device. Please wait..."
            
        case .deviceConnected:
            "Device connected successfully."
            
        case .scanningWifi:
            "Scanning available Wi-Fi networks..."
            
        case .wifiScanned:
            "Wi-Fi networks found."
            
        case .configuringWifi:
            "Configuring Wi-Fi. Please wait..."
            
        case .wifiConfigApplied:
            "Applying Wi-Fi settings..."
            
        case .wifiConfigured:
            "Device setup complete."
        }
    }
}

extension CuroProvisioningManager: ESPDeviceConnectionDelegate {
    public func getProofOfPossesion(forDevice: ESPDevice, completionHandler: @escaping (String) -> Void) {
        if let espDeviceId = self.espIdToConnect, espDeviceId.count > 6 {
            let pop = String(espDeviceId.suffix(6))
            print("getProofOfPossesion", pop)
//            completionHandler("P\(pop)")
            completionHandler("abcd1234")
        } else {
            completionHandler("abcd1234")
        }
    }
    
    public func getUsername(forDevice: ESPDevice, completionHandler: @escaping (String?) -> Void) {
        completionHandler("curotel")
    }
}

public protocol CuroProvisioningManagerDelegate {
    func onWiFiList(_ wifiList: [ESPWifiNetwork])
    func onStepUpdate(_ step: CuroAlphaProvisionStep)
    func onError(_ message: String)
}
