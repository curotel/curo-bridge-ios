//
//  BPReading.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 12/05/26.
//

import Foundation

public struct BPReading: Equatable {
    public var systolic:     Int
    public var diastolic:    Int
    public var heartRate:    Int
    public var livePressure: Int?

    public init() {
        self.systolic     = 0
        self.diastolic    = 0
        self.heartRate    = 0
        self.livePressure = nil
    }

    public init(systolic: Int, diastolic: Int, heartRate: Int, livePressure: Int? = nil) {
        self.systolic     = systolic
        self.diastolic    = diastolic
        self.heartRate    = heartRate
        self.livePressure = livePressure
    }
}
