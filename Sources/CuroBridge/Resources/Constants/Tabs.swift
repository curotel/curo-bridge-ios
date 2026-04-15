//
//  Tabs.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 14/04/26.
//

import SwiftUI

public struct TabItem {
    var title: String
    var icon: IconAsset
    
    func getIcon() -> Image {
        self.icon.image
    }
}

@MainActor public let physicianTabItems: [TabItem] = [
    .init(title: "History", icon: .records),
    .init(title: "Home", icon: .logo),
    .init(title: "Settings", icon: .settings)
]

@MainActor public let patientTabItems: [TabItem] = [
    .init(title: "Prescriptions", icon: .prescription),
    .init(title: "History", icon: .records),
    .init(title: "Home", icon: .logo),
    .init(title: "Care", icon: .careTeam),
    .init(title: "Settings", icon: .settings)
]
