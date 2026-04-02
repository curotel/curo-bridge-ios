//
//  Stopwatch.swift
//  curo-physicians
//
//  Created by Magnus Fernandes on 25/03/26.
//

import SwiftUI
import Combine

public struct Stopwatch: View {
    @State var timeInSeconds: Int
    @State var isRunning: Bool
    @State private var totalTime: Int
    
    var onCompleted: (() -> Void)?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var formattedTime: String {
        let minutes = timeInSeconds / 60
        let seconds = timeInSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: CGFloat {
        guard totalTime > 0 else { return 0 }
        return CGFloat(totalTime - timeInSeconds) / CGFloat(totalTime)
    }
    
    public init(timeInSeconds: Int, isRunning: Bool, onCompleted: (() -> Void)? = nil) {
        _timeInSeconds = State(initialValue: timeInSeconds)
        _isRunning = State(initialValue: isRunning)
        _totalTime = State(initialValue: timeInSeconds) // 👈 capture once
        self.onCompleted = onCompleted
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            
            IconAsset.stopwatch.image
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(12)
                .background(ThemeColor.white.color)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(ThemeColor.buttonGray.color, lineWidth: 1)
                )
                .overlay(
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            ThemeColor.blue.color,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1), value: progress)
                )
            
            Text(formattedTime)
                .font(.custom(AppFont.semibold.rawValue, size: 16))
                .foregroundStyle(ThemeColor.blue.color)
                .monospacedDigit()
        }
        .onReceive(timer) { _ in
            guard isRunning, timeInSeconds > 0 else { return }
            
            timeInSeconds -= 1
            
            if timeInSeconds == 0 {
                isRunning = false
                onCompleted?()
            }
        }
    }
}

#Preview {
    Stopwatch(timeInSeconds: 10, isRunning: true) {
        
    }
}

