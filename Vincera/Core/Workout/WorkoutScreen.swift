//
//  WorkoutScreen.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI

struct WorkoutScreen: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack {
                    SectionTitle("Today's Workout") {
                        Button(
                            "New Workout",
                            systemImage: "bolt.fill",
                            action: { handleStartDay() }
                        )
                    }
                        .padding(.horizontal, PADDING_INLINE)
                    if let split = store.currentSplit {
                        dayView(split)
                    } else {
                        emptyDayView
                    }
                }
                
                VStack {
                    HStack {
                        SectionTitle("Current Split") {
                            Button("View All", systemImage: "line.horizontal.3.decrease") {
                                Router.shared.push(SplitListRoute())
                            }
                        }
                    }
                    if let split = store.currentSplit {
                        CurrentSplitView(split: split)
                    } else {
                        EmptyCard(
                            title: "No Split Selected",
                            description: "Choose a split from our library or create your own to get started"
                        )
                    }
                }
                .padding(.horizontal, PADDING_INLINE)
                
                VStack {
                    BrandButton("Generate Split", systemImage: "sparkles") {
                        Router.shared.push(AssistedSplitRoute())
                    }
                    .primary
                    
                    BrandButton("Create Split", systemImage: "plus") {
                        Router.shared.push(SplitEditorRoute(split: nil))
                    }
                    .secondary
                }
                .padding(.horizontal, PADDING_INLINE)
            }
            .padding(.vertical, PADDING_TOP)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("Workout")
    }
    
    @ViewBuilder
    private func dayView(_ split: Writers.Split) -> some View {
        InfiniteCarousel(
            data: split.days,
            selectedTab: Binding(
                get: { (store.splitMeta.item.dayIndex ?? 0) + 1 },
                set: handleUpdateDayIndex
            ),
            height: 280,
            onTabChange: { store.setDayIndex($0) }) {
                WorkoutCarouselItem(
                    split: split,
                    day: $0,
                    startWorkout: handleStartDay
                )
            }
        CarouselIndicators()
    }
    
    @ViewBuilder
    private var emptyDayView: some View {
        VStack(spacing: 16) {
            EmptyCard(
                title: "No Split Selected",
                description: "Choose a split from our library or create your own to get started"
            )
            BrandButton("View Splits", systemImage: "list.bullet") {
                Router.shared.push(SplitListRoute())
            }
            .secondary
            BrandButton("Generate Split", systemImage: "sparkles") {
                Router.shared.push(AssistedSplitRoute())
            }
            .primary
        }
        .padding(.horizontal, PADDING_INLINE)
    }
    
    private func handleUpdateDayIndex(_ index: Int) {
        // carousel is 1-indexed
        guard let split = store.currentSplit else { return }
        if index == 0 { store.splitMeta.item.dayIndex = split.days.count - 1 }
        else if index == split.days.count + 1 { store.splitMeta.item.dayIndex = 0 }
        else { store.splitMeta.item.dayIndex = index - 1 }
    }
    
    func handleStartDay(_ day: Writers.Day? = nil) {
        do {
            try store.startWorkout(workout: day?.toActive() ?? Builder.ActiveWorkout.new())
            Router.shared.showWorkout = true
        } catch {
            Haptics.notify(.warning)
        }
    }
}
