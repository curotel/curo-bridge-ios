//
//  AlphaStatusManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 06/04/25.
//

import CoreBluetooth
import Foundation

public class AlphaStatusManager {
    weak public var delegate: AlphaStatusManagerDelegate?
    var espDeviceId: String? = nil
    
    private func deliverToMain(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    func processPayload(_ payload: Data) {
        let full = String(decoding: payload, as: UTF8.self)
        for lineSubseq in full.split(whereSeparator: \.isNewline) {
            let trimmed = String(lineSubseq).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            processLine(trimmed)
        }
    }
    
    private func processLine(_ line: String) {
        if line.starts(with: "STAT:") {
            processStatus(line)
        } else if line.starts(with: "ID:") {
            processCameraId(line)
        } else if line.starts(with: "IP:") {
            processDeviceIp(line)
        } else if line.starts(with: "SSID:") {
            processDeviceSsid(line)
        }
    }
    
    func processStatus(_ statusString: String) {
        let body = statusString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "STAT:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if let statusInt = Int(body), let curoStatus = CuroAlphaStatus(rawValue: statusInt) {
            self.delegate?.onDeviceStatus(curoStatus)
        }
    }
    
    func processCameraId(_ statusString: String) {
        let cameraID = statusString.replacingOccurrences(of: "ID:", with: "")
        self.espDeviceId = cameraID
        self.delegate?.onCameraIdReceived(cameraID)
    }
    
    func processDeviceIp(_ statusString: String) {
        let ipString = statusString.replacingOccurrences(of: "IP:", with: "")
        if ipString.count > 0 && ipString != "0.0.0.0" {
            self.delegate?.onIpReceived(ipString)
        }
    }
    
    func processDeviceSsid(_ statusString: String) {
        let trimmed = statusString.trimmingCharacters(in: .whitespacesAndNewlines)
        let ssidString = trimmed.replacingOccurrences(of: "SSID:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
        if !ssidString.isEmpty {
            self.delegate?.onSSIDReceived(ssidString)
        }
    }
}

public protocol AlphaStatusManagerDelegate: AnyObject {
    func onDeviceStatus(_ status: CuroAlphaStatus)
    func onCameraIdReceived(_ espId: String)
    func onIpReceived(_ deviceIp: String)
    func onSSIDReceived(_ ssid: String)
}
