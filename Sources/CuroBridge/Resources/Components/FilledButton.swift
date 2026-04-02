//
//  FilledButton.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 30/03/26.
//

import SwiftUI

public struct FilledButton: View {
    let title: String
    let background: Color
    let icon: Image?
    let isSelected: Bool
    let iconColor: Color
    let width: CGFloat?
    let textSize: CGFloat
    let action: (() -> Void)?
    
    public init(
        title: String,
        background: Color = .white,
        icon: Image? = nil,
        isSelected: Bool = false,
        iconColor: Color = ThemeColor.text.color,
        width: CGFloat? = nil,
        textSize: CGFloat = 16,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.background = background
        self.icon = icon
        self.isSelected = isSelected
        self.iconColor = iconColor
        self.width = width
        self.textSize = textSize
        self.action = action
    }
    
    public var body: some View {
        Button {
            (action ?? {})()
        } label: {
            HStack(spacing: 8) {
                
                if let icon = icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20)
                        .foregroundStyle(
                            isSelected
                            ? ThemeColor.white.color
                            : iconColor
                        )
                }
                
                Text(title)
                    .font(.custom(AppFont.semibold.rawValue, size: textSize))
                    .foregroundStyle(
                        isSelected
                        ? ThemeColor.white.color
                        : ThemeColor.black.color
                    )
            }
            .frame(maxWidth: width)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 50)
                    .fill(
                        isSelected
                        ? ThemeColor.black.color
                        : background
                    )
            )
        }
        .frame(maxWidth: width)
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    FilledButton(title: "Filled button")
}
