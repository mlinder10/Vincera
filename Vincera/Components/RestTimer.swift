//
//  RestTimer.swift
//  Vincera
//
//  Created by Matt Linder on 12/9/24.
//

import SwiftUI

fileprivate let CIRCLE_SIZE: CGFloat = 164

struct RestTimerView: View {
    @EnvironmentObject private var store: DataStore
    @State private var showCustom = false
    @State private var selectedDuration: Int = 60
    
    var body: some View {
        Card {
            VStack {
                toolbar
                if store.workoutTimer.show {
                    CountDownCircle()
                        .transition(.asymmetric(
                            insertion: .opacity.animation(.spring(.bouncy).delay(0.3)),
                            removal: .opacity.animation(.none)
                        ))
                        .padding(.top)
                        .overlay {
                            VStack {
                                Text(store.workoutTimer.duration.secondFormatted)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                TimerPicker(selectedDuration: $selectedDuration)
                            }
                        }
                }
            }
        }
        .onChange(of: store.workoutTimer.initialDuration) { store.workoutTimer.handleChange($0, $1) }
        .onChange(of: selectedDuration) { store.workoutTimer.initialDuration = $1 }
    }
    
    private var toolbar: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(store.workoutTimer.show ? 90 : 0))
                Text(store.workoutTimer.duration.secondFormatted)
                    .fontWeight(.semibold)
            }
            
            
            Spacer()
            
            if store.workoutTimer.duration > 0 {
                HStack {
                    Button("", systemImage: store.workoutTimer.isPaused ? "play.fill" : "pause") {
                        store.workoutTimer.togglePause()
                    }
                    .buttonBorderShape(.circle)
                    .buttonStyle(.borderedProminent)
                    if store.workoutTimer.show {
                        Text(store.workoutTimer.isPaused ? "Start" : "Pause")
                            .font(.subheadline)
                    }
                }
            }
            HStack {
                Button("", systemImage: "arrow.2.circlepath") {
                    store.workoutTimer.reset()
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.bordered)
                if store.workoutTimer.show {
                    Text("Reset")
                        .font(.subheadline)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation { store.workoutTimer.show.toggle() } }
    }
}

fileprivate struct CountDownCircle: View {
    @EnvironmentObject private var store: DataStore
    @State private var percentage: Double = 1
    
    var body: some View {
        Circle()
            .trim(from: 0, to: percentage)
            .rotation(.degrees(270))
            .stroke(.accent, lineWidth: 2)
            .frame(width: CIRCLE_SIZE, height: CIRCLE_SIZE)
            .onChange(of: store.workoutTimer.getPercentage()) { _, newValue in
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
