//
//  DeviceToken.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 03/04/26.
//

import Foundation

public struct SetDeviceTokenRequestBody: Encodable & Sendable {
    let voipToken: String
    let provider: String
    let providerName: String
    
    public init(voipToken: String, provider: String, providerName: String) {
        self.voipToken = voipToken
        self.provider = provider
        self.providerName = providerName
    }
}
