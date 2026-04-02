//
//  Binding.swift
//  CuroBridge
//
//  Created by Magnus Fernandes on 01/04/26.
//

import SwiftUI

public extension Binding {
    func unwrap<T>() -> Binding<T>? where Value == Optional<T> {
        guard let value = self.wrappedValue else { return nil }
        return Binding<T>(
            get: { value },
            set: { self.wrappedValue = $0 }
        )
    }
}
