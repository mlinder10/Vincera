//
//  TimerView.swift
//  Weights
//
//  Created by Matt Linder on 8/13/24.
//

import SwiftUI

struct TimerView: View {
  @State private var time: Int = 0
  private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
  let start: Date
  
  var body: some View {
    Text(formatTimer())
      .onReceive(timer) { value in
        self.time = Int(Date().timeIntervalSince(start))
      }
      .onAppear {
        self.time = Int(Date().timeIntervalSince(start))
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

