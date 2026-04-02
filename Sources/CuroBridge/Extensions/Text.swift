//
//  Text.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 31/03/26.
//

import SwiftUI

public extension Text {
    
    public func appFont(_ font: AppFont, size: CGFloat) -> some View {
        self.font(.custom(font.rawValue, size: size))
    }
    
    public func appColor(_ color: ThemeColor) -> some View {
        self.modifier(AppTextColorModifier(color: color.color))
    }
    
//    public func appColor(_ color: Color) -> some View {
//        self.modifier(AppTextColorModifier(color: color))
//    }
}

private struct AppTextColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.foregroundStyle(color)
        } else {
            content.foregroundColor(color)
        }
    }
}
