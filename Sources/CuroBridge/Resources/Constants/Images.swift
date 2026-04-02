//
//  Images.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 17/03/26.
//

import SwiftUI

public enum ImageAsset: String, CaseIterable {
    case splashBackground = "SplashBackground"
    case appIconAlternate = "AppIconAlternate"
    case fullLogo = "FullLogo"
    case fullLogoAlternate = "FullLogoAlternate"
    case welcomeBackground = "WelcomeBackground"
    case getStartedBackground = "GetStartedBackground"
    case loginBackground = "LoginBackground"
    case pageHeaderBackground = "PageHeaderBackground"
    case avatar = "AvatarImage"
    case deviceAlpha = "DeviceAlpha"
    case deviceBoth = "DeviceBoth"
    case deviceStethoscope = "DeviceStethoscope"
    case callerBackground = "CallerBackground"
    case setupLoading = "SetupLoading"
}

public extension ImageAsset {
    var image: Image {
        Image(self.rawValue)
    }
}
