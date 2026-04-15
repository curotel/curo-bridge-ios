//
//  ConfirmManager.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 30/03/26.
//

import Foundation
import Combine

@MainActor
public final class ConfirmManager: ObservableObject {
    public static let shared = ConfirmManager()
    
    @Published public var isPresented = false
    
    @Published public var title: String = ""
    @Published public var negativeText: String = ""
    @Published public var positiveText: String = ""
    
    public var onConfirm: (() -> Void)?
    public var onClose: (() -> Void)?
    
    public func show(
        title: String,
        negativeText: String,
        positiveText: String,
        onConfirm: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) {
        print("Showing confirm manager")
        self.title = title
        self.negativeText = negativeText
        self.positiveText = positiveText
        self.onConfirm = onConfirm
        self.onClose = onClose
        self.isPresented = true
    }
}
