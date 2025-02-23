//
//  TimerView.swift
//  Weights
//
//  Created by Matt Linder on 8/13/24.
//

import SwiftUI

struct TimerView: View {
    @State private var time: Int = 0
    @State private var timerRunning = true
    let start: Date
    
    var body: some View {
        Text(formatTimer())
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timerRunning = false
            }
    }
    
    private func startTimer() {
        timerRunning = true
        Task {
            while timerRunning {
                await MainActor.run {
                    self.time = Int(Date().timeIntervalSince(start))
                }
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    private func formatTimer() -> String {
        let min = self.time / 60
        let sec = self.time % 60
        let minDisp = min < 10 ? "0\(min)" : "\(min)"
        let secDisp = sec < 10 ? "0\(sec)" : "\(sec)"
        return "\(minDisp):\(secDisp)"
    }
}


