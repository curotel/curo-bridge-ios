//
//  MeetingCommands.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 09/05/26.
//

import Foundation

@MainActor
public enum MeetingCommand {
    case alphaConnected
    case alphaDisconnected
    case stethoscopeConnected
    case stethoscopeDisconnected
    case readTemperature
    case startOximeter
    case stopOximeter
    case startBP
    case stopBP
    case startOtoscope
    case stopOtoscope
    case changeLEDIntensity(Int)
    case startStethoscope
    case stopStethoscope
}

public extension MeetingCommand {

    // Single source of truth — no duplication between commandString and init
    private static let lookup: [(command: MeetingCommand, string: String)] = [
        (.alphaConnected,        "ALPHA_CONNECTED"),
        (.alphaDisconnected,     "ALPHA_DISCONNECTED"),
        (.stethoscopeConnected,  "STETHOSCOPE_CONNECTED"),
        (.stethoscopeDisconnected, "STETHOSCOPE_DISCONNECTED"),
        (.readTemperature,       "READ_TEMPERATURE"),
        (.startOximeter,         "START_OXI"),
        (.stopOximeter,          "STOP_OXI"),
        (.startBP,               "START_BP"),
        (.stopBP,                "STOP_BP"),
        (.startOtoscope,         "START_OTO"),
        (.stopOtoscope,          "STOP_OTO"),
        (.startStethoscope,      "START_STETH"),
        (.stopStethoscope,       "STOP_STETH"),
    ]

    var commandString: String {
        // LED is special — it embeds a value
        if case .changeLEDIntensity(let value) = self {
            return String(format: "LED_INTENSITY_%03d", max(0, min(100, value)))
        }
        // Everything else is in the table
        return Self.lookup.first { $0.command == self }?.string ?? ""
    }

    init?(_ commandString: String) {
        if commandString.hasPrefix("LED_INTENSITY_"),
           let value = Int(commandString.dropFirst("LED_INTENSITY_".count)) {
            self = .changeLEDIntensity(value)
            return
        }

        guard let match = Self.lookup.first(where: { $0.string == commandString }) else {
            return nil
        }
        self = match.command
    }
}

extension MeetingCommand: Equatable {}
