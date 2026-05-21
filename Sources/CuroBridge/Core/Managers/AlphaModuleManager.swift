//
//  AlphaModuleManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 07/04/25.
//

import Foundation

public class AlphaModuleManager {
    public var delegate: AlphaModuleManagerDelegate?
    
    private func deliverToMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    func processPayload(_ payload: Data) {
        let payloadStr = String(decoding: payload, as: UTF8.self)
        if payloadStr.starts(with: "OB:") {
            processTemperature(payloadStr)
        } else if payloadStr.starts(with: "HR:") {
            processOximeter(payloadStr)
        } else if payloadStr.starts(with: "FD:") {
            processFingerDetection(payloadStr)
        } else if payloadStr.starts(with: "V:") {
            processHealth(payloadStr)
        } else if payloadStr.starts(with: "BP:") {
            processBp(payloadStr)
        }
    }
    
    func processTemperature(_ payloadString: String) {
        let temperatures = payloadString.components(separatedBy: ",")
        if temperatures.count == 2 {
            let celsiusReading = temperatures[0].replacingOccurrences(of: "OB:", with: "")
            let celsius = Double(celsiusReading) ?? 0
            if celsius > 0 {
                deliverToMain { self.delegate?.onTemperatureReading(celsius, celsius.toFahrenheit()) }
            } else {
                deliverToMain { self.delegate?.onError(.temperatureReadingError) }
            }
        } else {
            deliverToMain { self.delegate?.onError(.temperatureReadingError) }
        }
    }
    
    func processOximeter(_ payloadString: String) {
        let oximeterReadings = payloadString.components(separatedBy: ",")
        if oximeterReadings.count == 2 {
            let pulseRateString = oximeterReadings[0].replacingOccurrences(of: "HR:", with: "")
            let oxygenSaturationString = oximeterReadings[1].replacingOccurrences(of: "O2:", with: "")
            
            let pulseRate = Double(pulseRateString) ?? 0
            var oxygenSaturation = Double(oxygenSaturationString) ?? 0
            
            if oxygenSaturation > 0 && oxygenSaturation < 100 {
                // delta fix
                if oxygenSaturation > 50 {
                    oxygenSaturation = oxygenSaturation + 1
                }
                let o2 = oxygenSaturation.rounded()
                let pr = Int(pulseRate.rounded())
                deliverToMain { self.delegate?.onOximetry(spo2: o2, pulse: pr) }
            } else {
                deliverToMain { self.delegate?.onError(.oximeterReadingError) }
            }
        } else {
            deliverToMain { self.delegate?.onError(.oximeterReadingError) }
        }
    }
    
    func processFingerDetection(_ payloadString: String) {
        let components = payloadString.components(separatedBy: ":")
        
        guard components.count == 2 else { return }
        
        let detected = components[1] == "1"
        self.delegate?.onFingerDetected(detected: detected)
    }
    
    func processBp(_ payloadString: String) {
        let cleaned = payloadString
            .replacingOccurrences(of: "\u{02}", with: "")
            .replacingOccurrences(of: "\u{03}", with: "")
            .replacingOccurrences(of: "BP:", with: "")
        
        var reading = BPReading()
        
        if cleaned.contains("C") && !cleaned.contains("P") {
            let pressureStr = String(cleaned.prefix(3))
            reading.livePressure = Int(pressureStr)
            self.delegate?.onBpReading(reading)
        }

        let parts = cleaned.split(separator: ";")
        
        for part in parts {
            let str = String(part)
            
            if str.hasPrefix("P") {
                let value = str.dropFirst() // 119081093
                
                if value.count >= 6 {
                    let sys = value.prefix(3)
                    let dia = value.dropFirst(3).prefix(3)
                    
                    if let systolic = Int(sys) {
                        reading.systolic = systolic
                    }
                    if let diastolic = Int(dia) {
                        reading.diastolic = diastolic
                    }
                }
            }
            
            if str.hasPrefix("R") {
                if let hr = Int(str.dropFirst()) {
                    reading.heartRate = hr
                }
            }
            
        }
        
        self.delegate?.onBpReading(reading)
    }
    
    func processHealth(_ payloadString: String) {
        var voltage: Double?
        var percentage: Double?

        var currentKey: Character?
        var buffer = ""

        for char in payloadString {
            if char == "V" || char == "P" || char == "C" {
                // Flush previous value
                if let key = currentKey, let value = Double(buffer) {
                    switch key {
                    case "V":
                        voltage = value
                    case "P":
                        percentage = min(value, 100)
                    default:
                        break
                    }
                }
                currentKey = char
                buffer = ""
            } else if char.isNumber || char == "." {
                buffer.append(char)
            }
        }

        // Flush last value
        if let key = currentKey, let value = Double(buffer) {
            switch key {
            case "V":
                voltage = value
            case "P":
                percentage = min(value, 100)
            default:
                break
            }
        }

        if let v = voltage, let p = percentage {
            self.delegate?.onHealth(v, p)
        } else {
            print("Invalid payload:", payloadString)
        }
    }
}

public enum ModuleError: Error {
    case temperatureReadingError
    case oximeterReadingError
}

extension ModuleError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .temperatureReadingError:
            return "Encountered an error while reading the temperature"
        case .oximeterReadingError:
            return "Encountered an error while reading the oximeter"
        }
    }
}

public protocol AlphaModuleManagerDelegate: AnyObject {
    func onHealth(_ voltage: Double, _ batteryLevel: Double)
    
    func onTemperatureReading(_ celsius: Double, _ fahrenheit: Double)
    func onOximetry(spo2: Double, pulse: Int)
    func onFingerDetected(detected: Bool)
    
    func onBpReading(_ reading: BPReading)
    
    func onError(_ error: ModuleError)
}
