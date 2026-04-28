//
//  PlanScreen.swift
//  Vincera
//
//  Created by Matt Linder on 3/24/26.
//

import SwiftUI

struct PlanScreen: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack {
                    SectionTitle("Current Split") {
                        Button("Create", systemImage: "plus") {
                            Router.shared.push(SplitEditorRoute(split: nil))
                        }
                    }
                    if let split = store.currentSplit {
                        CurrentSplitView(split: split)
                            .contentShape(Rectangle())
                            .onTapGesture { Router.shared.push(SplitEditorRoute(split: split)) }
                    } else {
                        EmptyCard(
                            title: "No Split Selected",
                            description: "Choose a split from our library or create your own to get started"
                        )
                    }
                }
                
                BrandButton("View Splits", systemImage: "list.bullet") {
                    Router.shared.push(SplitListRoute())
                }
                .secondary
                BrandButton("Generate Plan", systemImage: "sparkles") {
                    Router.shared.push(AssistedSplitRoute())
                }
                .primary
                
                VStack {
                    SectionTitle("Workouts") {
                        Button("Create", systemImage: "plus") {
                            Router.shared.push(WorkoutEditorRoute(workout: nil))
                        }
                    }
                    if store.workouts.isEmpty {
                        emptyWorkoutsView
                    } else {
                        workoutsListView
                    }
                }
            }
            .padding(.horizontal, PADDING_INLINE)
            .padding(.top, PADDING_TOP)
        }
    }
    
    private var workoutsListView: some View {
        LazyVStack {
            ForEach(store.workouts) { workout in
                WorkoutRow(workout: workout)
                    .contentShape(Rectangle())
                    .onTapGesture { Router.shared.push(WorkoutEditorRoute(workout: workout)) }
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

fileprivate struct CurrentSplitView: View {
    let split: Writers.Split
    
    var body: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(split.name)
                        .fontWeight(.semibold)
                    Text(split.description)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
                .padding(.trailing, 24)
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
}

#Preview {
    PlanScreen()
        .mockNavigation
        .mockEnvironment
}
