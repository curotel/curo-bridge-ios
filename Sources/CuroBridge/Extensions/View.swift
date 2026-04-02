//
//  View.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI

public extension View {
    public func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
