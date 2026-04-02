//
//  PageHeader.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 20/03/26.
//

import SwiftUI

public struct PageHeader: View {
    public var height: CGFloat
    
    public init(_ height: CGFloat? = nil) {
        self.height = height ?? getHeightByPercent(percent: 0.15)
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: height)
            .background(
                ImagePaint(
                    image: ImageAsset.pageHeaderBackground.image,
                    scale: 0.2
                )
            )
            .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    PageHeader()
}
