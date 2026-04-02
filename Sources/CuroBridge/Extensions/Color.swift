//
//  Color.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import SwiftUI

extension Color {
    static func theme(_ token: ThemeColor) -> Color {
        token.color
    }
}
