//
//  CustomBottomTabBar.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 24/03/26.
//

import SwiftUI

public struct TabItem {
    var title: String
    var icon: IconAsset
    
    func getIcon() -> Image {
        self.icon.image
    }
}

public struct CustomBottomTabBar: View {
    @Binding var selectedTab: Int
    
    var tabItems: [TabItem] = [
        .init(title: "Prescriptions", icon: .prescription),
        .init(title: "History", icon: .records),
        .init(title: "Home", icon: .logo),
        .init(title: "Care", icon: .careTeam),
        .init(title: "Settings", icon: .settings)
    ]
    
    public init(selectedTab: Binding<Int>) {
        _selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(alignment: .top) {
            ForEach(0 ..< tabItems.count, id: \.self) { index in
                Button {
                    selectedTab = index
                } label: {
                    GeometryReader { geo in
                        VStack(spacing: 5) {
                            tabItems[index].getIcon()
                                .resizable()
                                .scaledToFit()
                                .frame(width: index != 2 ? 24 : 36, height: index != 2 ? 24 : 36)
                                .foregroundStyle(
                                    index == selectedTab && index != 2 ? ThemeColor.accent.color : ThemeColor.buttonGray.color
                                )
                            
                            if index != 2 {
                                Text(tabItems[index].title)
                                    .font(.custom(AppFont.semibold.rawValue, size: 12))
                                    .foregroundStyle(
                                        index == selectedTab && index != 2 ? ThemeColor.blue.color : ThemeColor.buttonGray.color
                                    )
                            }
                        }
                        .frame(width: geo.size.width, height: geo.size.height)
                    }
                }
                .buttonStyle(PressableButtonStyle())

            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 5)
        .frame(height: 62)
    }
}

#Preview {
    CustomBottomTabBar(selectedTab: .constant(0))
}
