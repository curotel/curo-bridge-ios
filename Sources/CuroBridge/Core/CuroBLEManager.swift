//
//  CuroBLEManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 10/04/26.
//

import CoreBluetooth

@MainActor
public class CuroBLEManager {
    public static var shared: CuroBLEManager = .init()
    public var connectionMode: DeviceMode = .local
    
    // alpha characteristics
    var alphaStatusCharacteristic: CBCharacteristic?
    var alphaModuleCharacteristic: CBCharacteristic?
    var alphaStatusCommandTask: Task<Void, Never>?
    
    public var alphaStatusManager: AlphaStatusManager = .init()
    public var alphaModuleManager: AlphaModuleManager = .init()
    
    private var writeTask: Task<Void, Never>?
    private var readTask: Task<Void, Never>?
    private var writeQueue: [(CBPeripheral, Data, CBCharacteristic)] = []
    private var readQueue: [(CBPeripheral, CBCharacteristic)] = []
    private let writeDelay: Duration = .milliseconds(120)
    private let readDelay: Duration = .milliseconds(120)
    
    // stethoscope characteristics
    var stethoscopeCommandCharacteristic: CBCharacteristic?
    var stethoscopeVitalsCharacteristic: CBCharacteristic?
    var stethoscopeVitalsCommandTask: Task<Void, Never>?
    
    public var stethoscopeVitalsManager: StethoscopeVitalsManager = .init()
    public var stethoscopeDataManager: StethoscopeDataManager = .init()
    
    public func disconnectProtocol() {
        stopPingAlphaVitals()
    }
    
    public func checkCharacteristics(device: CBPeripheral, characteristic: CBCharacteristic) {
        print("Found characteristic: \(characteristic.uuid.uuidString)")
        switch characteristic.uuid {
        case CuroUUIDs.alphaStatusCharacteristic:
            alphaStatusCharacteristic = characteristic
            enableNotifyForCharacteristic(peripheral: device, characteristic: characteristic)
            if connectionMode == .local {
                writeToAlphaStatusCharacteristics(alphaDevice: device, command: .getSSID)
                writeToAlphaStatusCharacteristics(alphaDevice: device, command: .getESPID)
            } else if connectionMode == .provisioning {
                writeToAlphaStatusCharacteristics(alphaDevice: device, command: .getESPID)
            }
        case CuroUUIDs.alphaModuleCharacteristic:
            self.alphaModuleCharacteristic = characteristic
            enableNotifyForCharacteristic(peripheral: device, characteristic: characteristic)
            pingAlphaVitals(alphaDevice: device, characteristic: characteristic, command: .deviceHealth)
        case CuroUUIDs.stethoscopeVitalsCharacteristic:
            self.stethoscopeVitalsCharacteristic = characteristic
            self.pingStethoscopeVitals(stethoscopeDevice: device)
        case CuroUUIDs.stethoscopeDataCharacteristic:
            enableNotifyForCharacteristic(peripheral: device, characteristic: characteristic)
        case CuroUUIDs.stethoscopeCommandCharacteristic:
            self.stethoscopeCommandCharacteristic = characteristic
        default:
            print("Unknown characteristic: ", characteristic.uuid.uuidString)
        }
    }
}

extension CuroBLEManager {
    func enableNotifyForCharacteristic(peripheral: CBPeripheral?, characteristic: CBCharacteristic?) {
        if let peripheral = peripheral, let characteristic = characteristic {
            print("Enable notify for characteristic on \(peripheral.name ?? "Unknown device"): \(characteristic.uuid.uuidString)")
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
}

public extension CuroBLEManager {
    public func writeToAlphaModuleCharacteristics(
        alphaDevice: CBPeripheral,
        command: AlphaCommand
    ) {
        if let characteristic = alphaModuleCharacteristic {
            enqueueWrite(
                device: alphaDevice,
                data: command.toData(),
                characteristic: characteristic
            )
        }
    }
    
    public func writeToAlphaStatusCharacteristics(
        alphaDevice: CBPeripheral,
        command: AlphaCommand
    ) {
        if let characteristic = alphaStatusCharacteristic {
            enqueueWrite(
                device: alphaDevice,
                data: command.toData(),
                characteristic: characteristic
            )
        }
    }
    
    public func readAlphaStatus(_ device: CBPeripheral) {
        if let characteristic = alphaStatusCharacteristic {
            enqueueRead(device: device, characteristic: characteristic)
        }
    }
    
    public func readAlphaModule(_ device: CBPeripheral) {
        if let characteristic = alphaModuleCharacteristic {
            enqueueRead(device: device, characteristic: characteristic)
        }
    }
    
    private static func writeToDevice(device: CBPeripheral, data: Data, characteristic: CBCharacteristic) {
        let props = characteristic.properties
        let payloadDescription = String(decoding: data, as: UTF8.self)
        if props.contains(.write) {
            print("Writing to device (with response): \(characteristic.uuid.uuidString) \(payloadDescription)")
            device.writeValue(data, for: characteristic, type: .withResponse)
        } else if props.contains(.writeWithoutResponse) {
            print("Writing to device (without response): \(characteristic.uuid.uuidString) \(payloadDescription)")
            device.writeValue(data, for: characteristic, type: .withoutResponse)
        } else {
            print("Characteristic \(characteristic.uuid.uuidString) does not support write; cannot send: \(payloadDescription)")
        }
    }
    
    func processCharacteristics(device: CBPeripheral, characteristic: CBCharacteristic) {
        if let value = characteristic.value {
            if characteristic.uuid != CuroUUIDs.stethoscopeDataCharacteristic {
                print("Characteristic \(characteristic.uuid.uuidString) value: \(String(decoding: value, as: UTF8.self)) hex: \(value.toHexString())")
            }
            switch characteristic.uuid {
            case CuroUUIDs.alphaStatusCharacteristic:
                alphaStatusManager.processPayload(value)
            case CuroUUIDs.alphaModuleCharacteristic:
                alphaModuleManager.processPayload(value)
            case CuroUUIDs.stethoscopeVitalsCharacteristic:
                stethoscopeVitalsManager.processPayload(value)
            case CuroUUIDs.stethoscopeDataCharacteristic:
                stethoscopeDataManager.processPayload(value)
            default:
                print("Unhandled characteristics: \(characteristic.uuid.uuidString)")
            }
        }
    }
}

extension CuroBLEManager {
    func enqueueWrite(
        device: CBPeripheral,
        data: Data,
        characteristic: CBCharacteristic
    ) {
        writeQueue.append((device, data, characteristic))
        processWriteQueue()
    }
    
    private func processWriteQueue() {
        guard writeTask == nil else { return }
        
        writeTask = Task {
            while !writeQueue.isEmpty {
                let (device, data, characteristic) = writeQueue.removeFirst()
                
                Self.writeToDevice(
                    device: device,
                    data: data,
                    characteristic: characteristic
                )
                
                try? await Task.sleep(for: writeDelay)
            }
            
            writeTask = nil
        }
    }
}

extension CuroBLEManager {
    func enqueueRead(
        device: CBPeripheral,
        characteristic: CBCharacteristic
    ) {
        readQueue.append((device, characteristic))
        processReadQueue()
    }
    
    private func processReadQueue() {
        guard readTask == nil else { return }
        
        readTask = Task {
            while !readQueue.isEmpty {
                let (device, characteristic) = readQueue.removeFirst()
                
                device.readValue(for: characteristic)
                
                try? await Task.sleep(for: readDelay)
            }
            
            readTask = nil
        }
    }
}

public extension CuroBLEManager {
    public func resetDevice(_ peripheral: CBPeripheral) {
        writeToAlphaStatusCharacteristics(alphaDevice: peripheral, command: .resetESP)
    }
    
    func getOtoscopeUrl(deviceIP: String) -> URL? {
        return URL(string: "http://\(deviceIP):8081/stream")
    }
    
    func changeLedIntensity(alphaDevice: CBPeripheral, intensity: Double) {
        guard let characteristic = alphaModuleCharacteristic else { return }
        
        let value = max(0, min(100, Int(intensity.rounded())))
        let padded = String(format: "%03d", value)
        
        enqueueWrite(
            device: alphaDevice,
            data: "$L\(padded)!".toData(),
            characteristic: characteristic
        )
    }
}

// vitals
extension CuroBLEManager {
    public func pingAlphaVitals(
        alphaDevice: CBPeripheral,
        characteristic: CBCharacteristic,
        command: AlphaCommand
    ) {
        stopPingAlphaVitals()
        
        alphaStatusCommandTask = Task(operation: {
            while !Task.isCancelled {
                Self.writeToDevice(
                    device: alphaDevice,
                    data: command.toData(),
                    characteristic: characteristic
                )
                do {
                    try await Task.sleep(for: .seconds(30))
                } catch {
                    break
                }
            }
        })
    }
    
    public func stopPingAlphaVitals() {
        alphaStatusCommandTask?.cancel()
        alphaStatusCommandTask = nil
    }
    
    func pingStethoscopeVitals(stethoscopeDevice: CBPeripheral) {
        stopPingStethoscopeVitals()
        if let vitalsCharacteristics = self.stethoscopeVitalsCharacteristic {
            stethoscopeVitalsCommandTask = Task(operation: {
                while !Task.isCancelled {
                    self.enqueueRead(device: stethoscopeDevice, characteristic: vitalsCharacteristics)
                    do {
                        try await Task.sleep(for: .seconds(30))
                    } catch {
                        break
                    }
                }
            })
        }
    }
    
    func stopPingStethoscopeVitals() {
        stethoscopeVitalsCommandTask?.cancel()
        stethoscopeVitalsCommandTask = nil
    }
}

public extension CuroBLEManager {
    public func writeToStethoscopeCommandCharacteristics(stethoscopeDevice: CBPeripheral, command: StethoscopeCommand) {
        if let characteristic = stethoscopeCommandCharacteristic {
            enqueueWrite(
                device: stethoscopeDevice,
                data: command.toData(),
                characteristic: characteristic
            )
        }
    }
}
