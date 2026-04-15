//
//  CustomBottomTabBar.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 24/03/26.
//

import SwiftUI
import CuroBridge

public struct CustomBottomTabBar: View {
    @Binding var selectedTab: Int
    @State var tabItems: [TabItem]
    
    public init(tabItems: [TabItem], selectedTab: Binding<Int>) {
        self.tabItems = tabItems
        _selectedTab = selectedTab
    }
    
    var middleTabIndex: Int {
        tabItems.count / 2
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
                                .frame(width: index != middleTabIndex ? 24 : 36, height: index != middleTabIndex ? 24 : 36)
                                .foregroundStyle(
                                    index == selectedTab && index != middleTabIndex ? ThemeColor.accent.color : ThemeColor.buttonGray.color
                                )
                            
                            if index != middleTabIndex {
                                Text(tabItems[index].title)
                                    .font(.custom(AppFont.semibold.rawValue, size: 12))
                                    .foregroundStyle(
                                        index == selectedTab && index != middleTabIndex ? ThemeColor.blue.color : ThemeColor.buttonGray.color
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
    CustomBottomTabBar(tabItems: [], selectedTab: .constant(0))
}
