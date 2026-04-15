//
//  Constants.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 05/04/25.
//

import CoreBluetooth
import ESPProvision

public enum CuroUUIDs {
    // alpha settings
    public static var alphaService: CBUUID {
        .init(string: "06636aee-bdf4-421e-a9a5-04bbc6320e83")
    }
    static var alphaStatusCharacteristic: CBUUID {
        .init(string: "54C291C6-DD74-4283-95BD-89ABED5E672C")
    }
    static var alphaModuleCharacteristic: CBUUID {
        .init(string: "453CC59A-E08E-4D39-81C7-C59A45BD2DE9")
    }

    // stethoscope settings
    public static var stethoscopeService: CBUUID {
        .init(string: "cdb074c8-20d1-4408-b923-d4b0d7f91b9c")
    }
    static var stethoscopeStatusCharacteristic: CBUUID {
        .init(string: "03308a84-9c10-49b5-99af-089304ceba57") // read
    }
    static var stethoscopeDataCharacteristic: CBUUID {
        .init(string: "2542fe6a-00ef-440f-9656-00accf4688bf") // read & notify
    }
    static var stethoscopeCommandCharacteristic: CBUUID {
        .init(string: "280ce67c-9f8c-4a86-82a4-b896f935534d") // write & notify
    }
    static var stethoscopeVitalsCharacteristic: CBUUID {
        .init(string: "CDB074C8-20D1-4408-B923-D4B0D7F91B9E") // read
    }
    
    static var curoServices: [CBUUID] {
        [alphaService, stethoscopeService]
    }
}

public enum CuroDevice {
    case alpha
    case stethoscope
}

public enum CuroAlphaStatus: Int {
    case undefined = -1
    case noConfiguration = 0
    case notConnected = 1
    case connected = 2
    case otoscopeOn = 3
    case invalid = 4
}

public enum CuroAlphaProvisionStep {
    case idle
    case requestedDeviceId
    case receivedDeviceId
    case requestedSsid
    case receivedSsid
    case searchDevice
    case deviceConnected
    case scanningWifi
    case wifiScanned
    case configuringWifi
    case wifiConfigApplied
    case wifiConfigured
}

public let curoEspPrefix: String = "AVO-"

public enum DiscoveryType {
    case setup
    case local
    case remote
}

public enum CuroBridgeStatus {
    case idle
    case deviceConnected
}

public enum PeripheralUpdate {
    case alphaConnected
    case stethoscopeConnected
    case alphaDisconnected
    case stethoscopeDisconnected
}
