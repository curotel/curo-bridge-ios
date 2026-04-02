//
//  IconButtonStyle.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 18/03/26.
//

import SwiftUI

public struct IconButtonStyle: ButtonStyle {
    
    let width: CGFloat
    let height: CGFloat
    let padding: CGFloat
    let foregroundColor: Color
    let backgroundColor: Color
    let cornerRadius: CGFloat
    
    public init(
        width: CGFloat,
        height: CGFloat,
        padding: CGFloat,
        foregroundColor: Color,
        backgroundColor: Color,
        cornerRadius: CGFloat
    ) {
        self.width = width
        self.height = height
        self.padding = padding
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
    }
    
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .frame(maxWidth: width, maxHeight: height)
            .padding(.all, configuration.isPressed ? padding - 2 : padding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

public extension View {
    public func withIconButton(
        width: CGFloat = 18,
        height: CGFloat = 18,
        padding: CGFloat = 8,
        foregroundColor: Color = ThemeColor.text.color,
        backgroundColor: Color = ThemeColor.darkBackground.color,
        cornerRadius: CGFloat = 12
    ) -> some View {
        self.buttonStyle(IconButtonStyle(width: width, height: height, padding: padding, foregroundColor: foregroundColor, backgroundColor: backgroundColor, cornerRadius: cornerRadius))
    }
}
