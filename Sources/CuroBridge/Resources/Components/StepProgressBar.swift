//
//  StepProgressBar.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI

public struct StepProgressBar: View {
    @Binding public var currentStep: Int
    @State public var totalSteps: Int
    
    public var progress: Double {
        guard totalSteps > 0 else { return 0 }
        return Double(currentStep) / Double(totalSteps)
    }
    
    public init(currentStep: Binding<Int>, totalSteps: Int) {
        self._currentStep = currentStep
        self.totalSteps = totalSteps
    }
    
    public var body: some View {
        HStack(alignment: .center, spacing: 20) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                    
                    // Progress
                    Capsule()
                        .fill(ThemeColor.accent.color)
                        .frame(width: geo.size.width * progress, height: 6)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 6)
            
            Text("Step \(currentStep) of \(totalSteps)")
                .font(.custom(AppFont.semibold.rawValue, size: 14))
                .foregroundStyle(ThemeColor.text.color)
        }
    }
}

#Preview {
    StepProgressBar(currentStep: .constant(1), totalSteps: 5)
}
