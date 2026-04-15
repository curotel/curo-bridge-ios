//
//  CustomTabBar.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 19/03/26.
//

import SwiftUI

public struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    var tabItems: [String]
    
    public init(selectedTab: Binding<Int>, items: [String]) {
        self._selectedTab = selectedTab
        self.tabItems = items
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(0..<tabItems.count, id: \.self) { index in
                        Button {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred() // 👈 haptic
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedTab = index
                                proxy.scrollTo(index, anchor: .center)
                            }
                        } label: {
                            VStack(spacing: 6) {
                                
                                Text(tabItems[index])
                                    .font(.custom(AppFont.semibold.rawValue, size: 16))
                                    .foregroundStyle(
                                        index == selectedTab
                                        ? ThemeColor.text.color
                                        : ThemeColor.buttonGray.color
                                    )
                                    .fixedSize()
                                    .scaleEffect(selectedTab == index ? 1.05 : 1.0)
                                
                                ZStack {
                                    if selectedTab == index {
                                        Rectangle()
                                            .frame(height: 2)
                                            .foregroundStyle(ThemeColor.accent.color)
                                            .matchedGeometryEffect(id: "underline", in: animation)
                                    } else {
                                        Color.clear.frame(height: 2)
                                    }
                                }
                            }
                        }
                        .id(index)
                        .padding(.horizontal, 5)
                        .buttonStyle(PressableButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            .onChange(of: selectedTab) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    proxy.scrollTo(selectedTab, anchor: .center)
                }
            }
        }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(0), items: ["Home", "Settings"])
}
