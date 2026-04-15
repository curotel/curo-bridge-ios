//
//  AlphaModels.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/26.
//

enum AlphaModuleEvent {
    case temperature(Double)
    case spo2(Int)
    case pulse(Int)
    case bp(Int, Int, Int)
    case bpLive(Int)
    case battery(Int)
    case fingerDetected(Bool)
    case cuffAttached(Bool)
}

enum AlphaStatusEvent {
    case espID(String)
    case wifiStatus(Int)
    case ssid(String)
    case otoscopeIP(String)
    case otoscopeReady // STAT4
}

public enum DeviceMode {
    case local
    case remote
    case provisioning
}

enum ModuleType {
    case thermometer
    case oximeter
    case bp
    case otoscope
    case stethoscope
}
