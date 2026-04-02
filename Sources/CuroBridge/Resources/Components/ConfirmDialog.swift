//
//  ConfirmDialog.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 30/03/26.
//

import SwiftUI

public struct ConfirmDialog: View {
    let title: String
    let negativeText: String
    let positiveText: String
    let successClicked: () -> Void
    let failureClicked: () -> Void
    
    public init(title: String, negativeText: String, positiveText: String, successClicked: @escaping () -> Void, failureClicked: @escaping () -> Void) {
        self.title = title
        self.negativeText = negativeText
        self.positiveText = positiveText
        self.successClicked = successClicked
        self.failureClicked = failureClicked
    }
    
    public var body: some View {
        ZStack {
            ThemeColor.blue.color
                .ignoresSafeArea()
            
            VStack {
                Image(ImageAsset.fullLogoAlternate)
                    .resizable()
                    .scaledToFit()
                    .frame(width: getWidthByPercent(percent: 0.4))
                
                Spacer()
                    .frame(height: getHeightByPercent(percent: 0.05))
                    
                Text(title)
                    .font(.custom(AppFont.bold.rawValue, size: 16))
                    .foregroundStyle(ThemeColor.white.color)
                
                Spacer()
                    .frame(height: getHeightByPercent(percent: 0.1))
                
                HStack(spacing: 20) {
                    BorderedButton(
                        title: negativeText,
                        background: .blue,
                        borderColor: .white,
                        borderWidth: 2,
                        width: .infinity,
                        textSize: 14,
                        textColor: .white
                    ) {
                        failureClicked()
                    }
                    
                    FilledButton(
                        title: positiveText,
                        width: .infinity,
                        textSize: 14
                    ) {
                        successClicked()
                    }
                }
                .frame(width: getWidthByPercent(percent: 0.8))
            }
        }
    }
}

#Preview {
    ConfirmDialog(title: "Are you sure?", negativeText: "No", positiveText: "Yes") {
        
    } failureClicked: {
        
    }

}
