//
//  RestTimer.swift
//  Vincera
//
//  Created by Matt Linder on 12/9/24.
//

import SwiftUI

fileprivate let CIRCLE_SIZE: CGFloat = 164

struct RestTimerView: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var showCustom = false
    @State private var selectedDuration: Int = 60
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                toolbar
                if wStore.timer.show {
                    CountDownCircle()
                        .padding(.top)
                        .overlay {
                            VStack {
                                Text(wStore.timer.duration.secondFormatted)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                TimerPicker(selectedDuration: $selectedDuration)
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .backgroundRect(radius: 12, fill: Material.ultraThin)
            .onChange(of: wStore.timer.initialDuration) { wStore.timer.handleChange($0, $1) }
            .onChange(of: selectedDuration) { wStore.timer.initialDuration = $1 }
        }
    }
    
    private var toolbar: some View {
        HStack {
            Button { wStore.timer.show.toggle() } label: {
                HStack(spacing: 12) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(wStore.timer.show ? 90 : 0))
                    Text(wStore.timer.duration.secondFormatted)
                        .fontWeight(.semibold)
                }
            }
            .foregroundStyle(.primary)
            .buttonStyle(NoTapAnimationStyle())
            Spacer()
            if wStore.timer.duration > 0 {
                HStack {
                    Button { wStore.timer.togglePause() } label: {
                        Image(systemName: wStore.timer.isPaused ? "play.fill" : "pause")
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.borderedProminent)
                    if wStore.timer.show {
                        Text(wStore.timer.isPaused ? "Start" : "Pause")
                            .font(.subheadline)
                    }
                }
            }
            HStack {
                Button { wStore.timer.reset() } label: {
                    Image(systemName: "arrow.2.circlepath")
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.bordered)
                if wStore.timer.show {
                    Text("Reset")
                        .font(.subheadline)
                }
            }
        }
    }
}

fileprivate struct CountDownCircle: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var percentage: Double = 1
    
    var body: some View {
        Circle()
            .trim(from: 0, to: percentage)
            .rotation(.degrees(270))
            .stroke(.accent, lineWidth: 2)
            .frame(width: CIRCLE_SIZE, height: CIRCLE_SIZE)
            .onChange(of: wStore.timer.getPercentage()) { _, newValue in
                withAnimation { percentage = newValue }
            }
    }
}

fileprivate struct TimerPicker: View {
    @Binding var selectedDuration: Int
    
    var body: some View {
        Picker("", selection: $selectedDuration) {
            ForEach(1...(10 * 60 / 5), id: \.self) { num in
                Text((num * 5).secondFormatted).tag(num * 5)
            }
        }
    }
}
