//
//  WiFiProximity.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 28/03/26.
//

import SwiftUI

public struct WiFiProximity: View {
    var rssi: Int32
    var iconSize: CGFloat
    var showPercentage: Bool
    
    private var icons: [IconAsset] = [
        .wifi0,
        .wifi1,
        .wifi2,
        .wifi
    ]
    
    // Convert RSSI → 0–100 level
    private var level: Int {
        let rssiInt = Int(rssi)
        
        let clamped = min(max(rssiInt, -90), -30)
        let normalized = (clamped + 90) * 100 / 60
        
        return normalized
    }
    
    private var icon: IconAsset {
        let index = min(max(level / 25, 0), 3)
        return icons[index]
    }
    
    private var color: Color {
        Color(
            red: Double(100 - level) / 100,
            green: Double(level) / 100,
            blue: 0
        )
    }
    
    public init(rssi: Int32, iconSize: CGFloat = 24, showPercentage: Bool = false) {
        self.rssi = rssi
        self.iconSize = iconSize
        self.showPercentage = showPercentage
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            Image(icon.rawValue)
                .resizable()
                .foregroundStyle(color)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            
            if showPercentage {
                Text("\(level)%")
                    .font(.custom(AppFont.bold.rawValue, size: 14))
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    WiFiProximity(rssi: 0, iconSize: 24, showPercentage: false)
}
