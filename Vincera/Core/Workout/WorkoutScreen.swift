//
//  WorkoutScreen_.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI

struct WorkoutScreen_: View {
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
//                    BrandButton("View Splits", systemImage: "list.bullet") {
//                        Router.shared.push(SplitListRoute())
//                    }
//                    .secondary
                    BrandButton("Generate Plan", systemImage: "sparkles") {
                        Router.shared.push(AssistedSplitRoute())
                    }
                    .primary
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
                    get: { (store.splitMeta.item.dayIndex ?? 0) + 1 },
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
        guard let split = store.currentSplit else { return }
        if index == 0 { store.splitMeta.item.dayIndex = split.days.count - 1 }
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
