//
//  SSIDManager.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 28/03/26.
//

import Foundation
import NetworkExtension
import CoreLocation
import Combine

@MainActor
public final class WiFiSSIDManager: NSObject, ObservableObject {
    
    public static let shared = WiFiSSIDManager()
    
    @Published public private(set) var ssid: String?
    @Published public private(set) var isAuthorized: Bool = false
    
    private let locationManager = CLLocationManager()
    
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    // MARK: - Public API
    
    public func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    public func refreshSSID() async {
        guard isAuthorized else { return }
        ssid = await fetchSSID()
    }
    
    public func getSSID() async -> String? {
        if !isAuthorized {
            requestPermission()
            return nil
        }
        
        let value = await fetchSSID()
        ssid = value
        return value
    }
    
    public func isConnected(to prefix: String) async -> Bool {
        let current = await getSSID()
        return current?.hasPrefix(prefix) == true
    }
    
    // MARK: - Private
    
    private func fetchSSID() async -> String? {
        await withCheckedContinuation { continuation in
            NEHotspotNetwork.fetchCurrent { network in
                continuation.resume(returning: network?.ssid)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WiFiSSIDManager: @MainActor CLLocationManagerDelegate {
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            
            Task {
                await refreshSSID()
            }
            
        default:
            isAuthorized = false
            ssid = nil
        }
    }
}
