//
//  HistoryTab.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct HistoryTab: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ScrollView {
            VStack {
                PRView()
                    .padding(.horizontal)
                GraphsView()
                WorkoutsView()
                    .padding(.horizontal)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("History")
        // TODO: implement
        //    .toolbar {
        //      ToolbarItem(placement: .topBarTrailing) {
        //        Button { router.goTo(.settings) } label: {
        //          Image(systemName: "gearshape")
        //        }
        //      }
        //    }
    }
}

fileprivate struct PRView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var wStore: WorkoutStore
    private let columns = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            HStack {
                Text("Personal Records")
                    .fontWeight(.semibold)
                Spacer()
                Button { router.goTo(.createPr) } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .font(.subheadline)
            }
            if wStore.meta.prs.isEmpty { empty }
            else { prList }
        }
    }
    
    var empty: some View {
        VStack {
            Text("No Data Available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    var prList: some View {
        LazyVGrid(columns: columns) {
            ForEach(wStore.getPrs()) {
                PRCell(pr: $0)
            }
        }
    }
}

fileprivate struct PRCell: View {
    @EnvironmentObject private var eStore: ExerciseStore
    let pr: PRTrackerValues
    var exercise: ListExercise { eStore.getExercise(pr.listId) ?? ListExercise.UNKNOWN }
    
    var body: some View {
        VStack(spacing: 6) {
            pr.type.label
                .fontWeight(.semibold)
            Text(exercise.name)
                .font(.caption)
            if let valOne = pr.valOne, let valTwo = pr.valTwo {
                HStack {
                    if pr.type == .reps {
                        Text(valTwo.formatted())
                        Text("x")
                    }
                    Text(valOne.formatted())
                        .font(.title)
                        .fontWeight(.bold)
                    if pr.type == .weight {
                        Text("x")
                        Text(valTwo.formatted())
                    }
                }
            } else {
                Text("No Data Avaliable")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .backgroundRect(radius: 16, fill: .regularMaterial)
    }
}

fileprivate struct GraphsView: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var timeframe: Timeframe = .week
    private var workouts: [Workout] { wStore.getWorkouts(timeframe: timeframe) }
    
    var body: some View {
        VStack {
            HStack {
                Text("Recent Data")
                    .fontWeight(.semibold)
                Spacer()
                Picker("Timeframe", selection: $timeframe) {
                    ForEach(Timeframe.allCases) {
                        Text($0.rawValue)
                            .tag($0)
                    }
                }
            }
            .padding(.horizontal)
            if workouts.isEmpty { empty }
            else { graphs }
        }
    }
    
    var empty: some View {
        VStack {
            Text("No Data Available")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical)
    }
    
    var graphs: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                VolumeGraph(workouts: workouts)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
                TimeGraph(workouts: workouts)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
                BodyPartGraph(timeframe: timeframe)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .contentMargins(16)
        .scrollIndicators(.hidden)
    }
}

fileprivate struct WorkoutsView: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var timeframe: Timeframe = .week
    @State private var search = ""
    var workouts: [Workout] { wStore.getFiltered(search, timeframe).sortedByDate() }
    
    var body: some View {
        LazyVStack {
            CustomSearchbar(searchText: $search)
            HStack {
                Text("Past Workouts")
                    .fontWeight(.semibold)
                Spacer()
                Picker("Timeframe", selection: $timeframe) {
                    ForEach(Timeframe.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
            }
            ForEach(workouts) { workout in
                WorkoutCell(workout: workout)
                if workout.id != workouts.last?.id { Divider() }
            }
        }
    }
}

fileprivate struct WorkoutCell: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var wStore: WorkoutStore
    @EnvironmentObject private var eStore: ExerciseStore
    @State var workout: Workout
    
    var body: some View {
        Button {
            router.goTo(.pastWorkout(Binding(get: { workout }, set: { workout = $0 })))
        } label: {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.fromHex(workout.color))
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading) {
                    HStack {
                        Text(workout.name)
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(workout.start.formatted())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(workout.exercises.getBodyParts(eStore))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .foregroundStyle(.primary)
        .overlay {
            HStack {
                Spacer()
                Menu("", systemImage: "ellipsis.circle") {
                    Button(role: .destructive) { handleDelete() } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
    }
    
    func handleDelete() {
        do {
            try wStore.deleteWorkout(workout)
        } catch {
            router.notify(.danger, "Error deleting \(workout.name)")
        }
    }
}

#Preview {
    HistoryTab()
}
