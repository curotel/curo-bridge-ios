//
//  BatteryIcon.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 20/03/26.
//

import SwiftUI

public struct BatteryLevel: View {
    @Binding var level: Double
    var iconSize: CGFloat
    var showPercentage: Bool
    
    private var icons: [IconAsset] = [
        .battery0,
        .battery1,
        .battery2,
        .battery3,
        .battery4,
    ]
    
    // Clamp level between 0–100
    private var clampedLevel: Double {
        min(max(level ?? 0, 0), 100)
    }
    
    // Map level → index (0–4)
    private var icon: IconAsset {
        let index = Int((clampedLevel / 100) * Double(icons.count - 1))
        return icons[min(index, icons.count - 1)]
    }
    
    // Dynamic color (red → green)
    private var color: Color {
        Color(
            red: (100 - clampedLevel) / 100,
            green: clampedLevel / 100,
            blue: 0
        )
    }
    
    // Display text
    private var percentageText: String {
        "\(Int(clampedLevel))%"
    }
    
    public init(level: Binding<Double>, iconSize: CGFloat = 20, showPercentage: Bool = false) {
        self._level = level
        self.iconSize = iconSize
        self.showPercentage = showPercentage
    }
    
    public var body: some View {
        HStack(spacing: 5) {
            icon.image
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(color)
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
            
            if showPercentage {
                Text(percentageText)
                    .font(.custom(AppFont.bold.rawValue, size: 14))
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    BatteryLevel(level: .constant(20))
}
