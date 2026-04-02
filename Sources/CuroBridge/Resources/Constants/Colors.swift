//
//  Colors.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 17/03/26.
//

import SwiftUI

public enum ThemeColor: String, CaseIterable {
    case accent = "AccentColor"
    case white = "AppWhiteColor"
    case blue = "AppBlueColor"
    case green = "AppGreenColor"
    case darkBackground = "AppDarkBackgroundColor"
    case lightBackground = "AppLightBackgroundColor"
    case buttonGray = "AppButtonGrayColor"
    case buttonGrayLight = "AppButtonGrayLightColor"
    case text = "AppTextColor"
    case textSecondary = "AppTextGrayColor"
    case red = "AppRedColor"
    case black = "AppBlackColor"
    case yellow = "AppYellowColor"
    case blueDark = "AppBlueDarkColor"
    case blueLight = "AppBlueLightColor"
    case inputBackground = "AppInputBackgroundColor"
}

public extension ThemeColor {
    var color: Color {
        Color(self.rawValue)
    }
}
