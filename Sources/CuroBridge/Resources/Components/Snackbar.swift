//
//  Snackbar.swift
//  AlphaPhysician
//
//  Created by Magnus Fernandes on 09/05/24.
//

import SwiftUI

public struct Snackbar: Equatable {
    var message: String
    var duration: CGFloat
    
    public init(message: String, duration: CGFloat = 3.5) {
        self.message = message
        self.duration = duration
    }
}

public struct SnackbarView: View {
    var message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var body: some View {
        HStack(alignment: .center, content: {
            Text(message)
                .appFont(.bold, size: 14)
                .appColor(.white)
            
            Spacer()
        })
        .padding()
        .frame(width: maxWidth)
        .background(ThemeColor.blue.color)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}

public struct SnackbarModifier: ViewModifier {
    @Binding var snackbar: Snackbar?
    @State private var workItem: DispatchWorkItem?
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                ZStack {
                    mainSnackbarView()
                        .offset(y: 10)
                }.animation(.spring(), value: snackbar)
            }
            .onChange(of: snackbar, perform: { _ in
                showSnackbar()
            })
    }
    
    @ViewBuilder func mainSnackbarView() -> some View {
        if let snackbar = snackbar {
            VStack {
                SnackbarView(message: snackbar.message)
                Spacer()
            }
        }
    }
    
    private func showSnackbar() {
        guard let snackbar = snackbar else { return }
        
        UIImpactFeedbackGenerator(style: .light)
            .impactOccurred()
        
        if snackbar.duration > 0 {
            workItem?.cancel()
            
            let task = DispatchWorkItem {
                dismissSnackbar()
            }
            
            workItem = task
            DispatchQueue.main.asyncAfter(deadline: .now() + snackbar.duration, execute: task)
        }
    }
    
    private func dismissSnackbar() {
        withAnimation {
            snackbar = nil
        }
        
        workItem?.cancel()
        workItem = nil
    }
}

public extension View {
    func snackbarView(snackbar: Binding<Snackbar?>) -> some View {
        self.modifier(SnackbarModifier(snackbar: snackbar))
    }
}
