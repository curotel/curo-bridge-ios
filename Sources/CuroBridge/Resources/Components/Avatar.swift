//
//  Avatar.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 20/03/26.
//

import SwiftUI

public struct Avatar: View {
    @Binding var name: String
    
    public init(name: Binding<String>) {
        self._name = name
    }
    
    public var body: some View {
        HStack(spacing: 20) {
            ImageAsset.avatar.image
                .resizable()
                .scaledToFill()
                .frame(
                    width: getWidthByPercent(percent: 0.2),
                    height: getWidthByPercent(percent: 0.2)
                )
                .clipShape(Circle())
                .padding(5)
                .background(
                    ThemeColor.lightBackground.color
                        .clipShape(Circle())
                )
            
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: getHeightByPercent(percent: 0.08))
                
                Text("Hello")
                    .font(.custom(AppFont.bold.rawValue, size: 28))
                    .foregroundStyle(ThemeColor.text.color)
                
                Text(name)
                    .font(.custom(AppFont.bold.rawValue, size: 28))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [ThemeColor.blue.color, ThemeColor.green.color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: maxWidth)
    }
}

#Preview {
    Avatar(name: .constant("Magnus"))
}
