//
//  BluetoothDeviceListItem.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 10/04/26.
//

import SwiftUI
import CoreBluetooth

public struct BluetoothDeviceListItem: View {
    @Binding var device: CBPeripheral
    var onClick: () -> Void
    
    public init(device: Binding<CBPeripheral>, onClick: @escaping () -> Void) {
        self._device = device
        self.onClick = onClick
    }
    
    public var body: some View {
        Button {
            onClick()
        } label: {
            HStack {
                IconAsset.device.image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundStyle(ThemeColor.text.color)
                
                Text(device.name ?? "Unknown device")
                    .font(.custom(AppFont.semibold.rawValue, size: 14))
                    .foregroundStyle(ThemeColor.text.color)
                
                Spacer()
            }
            .padding()
            .frame(width: maxWidth)
            .background(
                ThemeColor.lightBackground.color
            )
            .clipShape(
                RoundedRectangle(cornerRadius: 16)
            )
        }
        .buttonStyle(PressableButtonStyle())
    }
}
