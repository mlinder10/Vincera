//
//  WorkoutScreen.swift
//  Weights
//
//  Created by Matt Linder on 8/7/24.
//

import SwiftUI

struct WorkoutScreen: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack {
                    SectionTitle("Today's Workout")
                        .padding(.horizontal, PADDING_INLINE)
                    if let split = store.currentSplit {
                        dayView(split)
                    } else {
                        emptyDayView
                    }
                }
                
                WorkoutsView() {
                    handleStartWorkout($0)
                }
                .padding(.horizontal, PADDING_INLINE)
            }
            .padding(.top, PADDING_TOP)
        }
    }
    
    private func dayView(_ split: Writers.Split) -> some View {
        Group {
            InfiniteCarousel(
                data: split.days,
                selectedTab: Binding(
                    get: { (store.splitMeta.dayIndex ?? 0) + 1 },
                    set: handleUpdateDayIndex
                ),
                height: 240,
                onTabChange: { store.setDayIndex($0) }) {
                    WorkoutCarouselItem(
                        split: split,
                        day: $0,
                        startWorkout: handleStartDay
                    )
                }
            CarouselIndicators()
        }
    }
    
    private var emptyDayView: some View {
        VStack(spacing: 16) {
            EmptyCard(
                title: "No Split Selected",
                description: "Choose a split from our library or create your own to get started"
            )
            BrandButton("View Splits", systemImage: "list.bullet") {
                Router.shared.tab = .plan
                Router.shared.push(SplitListRoute())
            }
            .secondary
            BrandButton("Generate Split", systemImage: "sparkles") {
                Router.shared.tab = .plan
                Router.shared.push(AssistedSplitRoute())
            }
            .primary
        }
        .padding(.horizontal, PADDING_INLINE)
    }
    
    private func handleUpdateDayIndex(_ index: Int) {
        guard let split = store.currentSplit else { return }
        if index == 0 { store.splitMeta.dayIndex = split.days.count - 1 }
        else { store.splitMeta.dayIndex = index - 1 }
    }
    
    func handleStartDay(_ day: Writers.Day? = nil) {
        do {
            try store.startWorkout(workout: day?.toActive() ?? Builder.ActiveWorkout.new())
            Router.shared.showWorkout = true
        } catch {
            Haptics.notify(.warning)
        }
    }
    
    func handleStartWorkout(_ workout: Writers.Workout? = nil) {
        do {
            try store.startWorkout(workout: workout?.toActive() ?? Builder.ActiveWorkout.new())
            Router.shared.showWorkout = true
        } catch {
            Haptics.notify(.warning)
        }
    }
}

fileprivate struct WorkoutsView: View {
    @EnvironmentObject private var store: DataStore
    let startWorkout: (Writers.Workout?) -> Void
    
    var body: some View {
        VStack {
            SectionTitle("Workouts") {
                Button("Start", systemImage: "bolt.fill") {
                    startWorkout(nil)
                }
            }
            if store.workouts.isEmpty {
                emptyWorkoutsView
            } else {
                workoutsListView
            }
        }
    }
    
    private var workoutsListView: some View {
        LazyVStack {
            ForEach(store.workouts) { workout in
                WorkoutRow(workout: workout)
                    .containerShape(Rectangle())
                    .onTapGesture { startWorkout(workout) }
            }
        }
    }
    
    private var emptyWorkoutsView: some View {
        EmptyCard(
            title: "No Workouts Saved",
            description: "Individual workouts that you create will be displayed here"
        )
    }
}

#Preview {
    WorkoutScreen()
        .mockNavigation
        .mockEnvironment
}
