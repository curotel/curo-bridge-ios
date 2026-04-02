//
//  BorderedButton.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI

public struct BorderedButton: View {
    let title: String
    let background: Color
    let borderColor: Color
    let borderWidth: CGFloat
    let icon: Image?
    let isSelected: Bool
    let iconColor: Color
    let width: CGFloat?
    let textSize: CGFloat
    let textColor: Color
    let action: (() -> Void)?
    
    public init(
        title: String,
        background: Color = ThemeColor.white.color,
        borderColor: Color = ThemeColor.text.color,
        borderWidth: CGFloat = 1,
        icon: Image? = nil,
        isSelected: Bool = false,
        iconColor: Color = ThemeColor.text.color,
        width: CGFloat? = nil,
        textSize: CGFloat = 16,
        textColor: Color = ThemeColor.text.color,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.background = background
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.icon = icon
        self.isSelected = isSelected
        self.iconColor = iconColor
        self.width = width
        self.textSize = textSize
        self.textColor = textColor
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
                            isSelected ? ThemeColor.white.color : iconColor
                        )
                }
                
                Text(title)
                    .font(.custom(AppFont.semibold.rawValue, size: textSize))
                    .foregroundStyle(
                        isSelected
                        ? ThemeColor.white.color
                        : textColor
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
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .frame(maxWidth: width)
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    BorderedButton(title: "Bordered button")
}
