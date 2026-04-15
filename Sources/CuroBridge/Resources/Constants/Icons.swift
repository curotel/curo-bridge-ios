//
//  Icons.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 02/04/26.
//

import SwiftUI

public enum IconAsset: String, CaseIterable {
    case app = "AppIcon"
    case close = "CloseIcon"
    case phone = "PhoneIcon"
    case lock = "LockIcon"
    case email = "EmailIcon"
    case apple = "AppleIcon"
    case google = "GoogleIcon"
    case prescription = "PrescriptionIcon"
    case records = "RecordsIcon"
    case careTeam = "CareTeamIcon"
    case settings = "SettingsIcon"
    case logo = "LogoIcon"
    case fileUpload = "FileUploadIcon"
    case scan = "ScanIcon"
    case consultation = "ConsultationIcon"
    case endCall = "EndCallIcon"
    case invert = "InvertIcon"
    case point = "PointIcon"
    case disconnect = "DisconnectIcon"
    case temperature = "TemperatureIcon"
    case heart = "HeartIcon"
    case tank = "TankIcon"
    case check = "CheckIcon"
    case stopwatch = "StopwatchIcon"
    case resend = "ResendIcon"
    case bluetooth = "BluetoothIcon"
    case device = "DeviceIcon"
    case router = "RouterIcon"
    case history = "HistoryIcon"
    
    case playerPause = "PlayerPauseIcon"
    case playerPlay = "PlayerPlayIcon"
    
    case increase = "IncreaseIcon"
    case decrease = "DecreaseIcon"
    
    case male = "MaleIcon"
    case female = "FemaleIcon"
    
    case battery0 = "Battery0Icon"
    case battery1 = "Battery1Icon"
    case battery2 = "Battery2Icon"
    case battery3 = "Battery3Icon"
    case battery4 = "Battery4Icon"
    
    case wifi = "WiFiIcon"
    case wifi0 = "WiFiIcon0"
    case wifi1 = "WiFiIcon1"
    case wifi2 = "WiFiIcon2"
    
    case arrowLeft = "ArrowLeftIcon"
    case arrowRight = "ArrowRightIcon"
    
    case bolt = "BoltIcon"
    case boltOff = "BoltOffIcon"
    
    case eye = "EyeIcon"
    case eyeOff = "EyeOffIcon"
}

public extension IconAsset {
    var image: Image {
        Image(self.rawValue, bundle: .module)
    }
}
