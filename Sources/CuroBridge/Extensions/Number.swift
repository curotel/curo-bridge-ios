//
//  Number.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 31/03/26.
//

import Foundation

public extension Double {
    func toFahrenheit() -> Double {
        let fahrenheit = (self * 9/5) + 32
        return Double(String(format: "%.1f", fahrenheit)) ?? 0.0
    }
    
    /// Safely converts to Int using rounding
    func toInt() -> Int {
        return Int(self.rounded())
    }
    
    /// Rounds to given decimal places (returns Double)
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
    
    /// Precise rounding using Decimal (for finance / accuracy)
    func roundedDecimal(to places: Int) -> Decimal {
        var value = Decimal(string: String(self)) ?? Decimal(self)
        var result = Decimal()
        NSDecimalRound(&result, &value, places, .plain)
        return result
    }
}
