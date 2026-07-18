//
//  ActiveWorkout.swift
//  Vincera
//
//  Created by Matt Linder on 11/4/24.
//

import SwiftUI

struct ActiveWorkoutCollapsed: View {
    let workout: Builder.ActiveWorkout
    
    var body: some View {
        VStack {
            HStack {
                Text(workout.name)
                Spacer()
                TimerView(start: workout.startedAt)
            }
            ProgressView(value: workout.progress())
        }
        .onTapGesture { Router.shared.showWorkout = true }
    }
}

struct ActiveWorkoutDisplayer: ViewModifier {
    @ObservedObject private var router = Router.shared
    @EnvironmentObject private var store: DataStore
    
    func body(content: Content) -> some View {
        if let workout = store.activeWorkout.item, !router.showWorkout {
            content
                .tabViewBottomAccessory {
                    ActiveWorkoutCollapsed(workout: workout)
                        .contentShape(Capsule())
                        .padding(.horizontal)
                        .onTapGesture { router.showWorkout = true }
                }
        } else {
            content
        }
    }
}

extension View {
    var activeWorkoutDisplayer: some View {
        self.modifier(ActiveWorkoutDisplayer())
    }
}
