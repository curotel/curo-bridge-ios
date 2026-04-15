//
//  View.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI

public extension View {
    public func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
    
    public func appColor(_ color: ThemeColor) -> some View {
        self.modifier(AppViewColorModifier(color: color.color))
    }
}

private struct AppViewColorModifier: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.foregroundStyle(color)
        } else {
            content.foregroundColor(color)
        }
    }
}
