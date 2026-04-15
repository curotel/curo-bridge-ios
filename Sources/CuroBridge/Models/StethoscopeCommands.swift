//
//  StethoscopeCommands.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 14/04/26.
//

import Foundation

public enum StethoscopeCommand: String {
    case startStethoscope = "$STRT!"
    case stopStethoscope = "$STOP!"
}


public extension StethoscopeCommand {
    func toData() -> Data {
        self.rawValue.data(using: .utf8)!
    }
}
