//
//  StethoscopeDataManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 14/04/26.
//

import Foundation

public class StethoscopeDataManager {
    public var delegate: StethoscopeDataManagerDelegate?
    
    func processPayload(_ payload: Data) {
        self.delegate?.onData(payload)
    }
}

public protocol StethoscopeDataManagerDelegate: AnyObject {
    func onData(_ data: Data)
}
