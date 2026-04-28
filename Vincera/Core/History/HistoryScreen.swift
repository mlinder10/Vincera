//
//  HistoryScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct HistoryScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var date = Date()
    private var components: CalendarComponents {
        date.getComponents()
    }
    private var workouts: [Writers.CompletedWorkout] {
        store.getFiltered(during: components)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                PRView()
                    .padding(.horizontal, PADDING_INLINE)
                
                CalendarView(date: $date) {
                    CalendarDayView(workouts: workouts, components: $0)
                }
                .padding(.horizontal, PADDING_INLINE)
                
                GraphsView(workouts: workouts, components: components)
                
                if !workouts.isEmpty {
                    WorkoutsView(workouts: workouts)
                        .padding(.horizontal, PADDING_INLINE)
                }
            }
            .padding(.vertical, PADDING_TOP)
        }
    }
}

fileprivate struct CalendarDayView: View {
    let workouts: [Writers.CompletedWorkout]
    let components: CalendarComponents
    private var color: Color {
        if workouts.contains(
            where:{ $0.startedAt.getComponents().day == components.day }
        ) { return .accent.opacity(0.4) }
        if components.isToday { return .blue.opacity(0.3) }
        return .clear
    }
    
    var body: some View {
        Text(String(components.day))
            .font(.caption)
            .frame(width: 24, height: 24)
            .background(Circle().fill(color))
    }
}

fileprivate struct PRView: View {
    @EnvironmentObject private var store: DataStore
    private let columns = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            SectionTitle("Personal Records") {
                Button("Edit", systemImage: "pencil") {
                    Router.shared.push(CreatePRRoute())
                }
            }
            if store.trackers.isEmpty {
                EmptyCard(
                    title: "No Personal Records Tracked",
                    description: "Edit your personal records list to keep an eye on your best lifts"
                )
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(store.getPrs()) {
                        PRCell(pr: $0)
                    }
                }
            }
        }
    }
}

fileprivate struct PRCell: View {
    let pr: Writers.PRTrackerValues
    var exercise: ListExercise { ExerciseList.shared.getExercise(pr.listId) ?? ListExercise.UNKNOWN }
    
    var body: some View {
        Card {
            VStack(spacing: 6) {
                Label(pr.type.rawValue, systemImage: pr.type.icon)
                    .fontWeight(.semibold)
                Text(exercise.name)
                    .font(.caption)
                
                if let one = pr.valOne, let two = pr.valTwo { values(one, two) }
                else { empty }
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func values(_ one: Double, _ two: Double) -> some View {
        HStack {
            if pr.type == .reps {
                Text(one.formatted())
                Text("x")
            }
            
            Text(one.formatted())
                .font(.title)
                .fontWeight(.bold)
            
            if pr.type == .weight {
                Text("x")
                Text(two.formatted())
            }
        }
    }
    
    private var empty: some View {
        Text("No Data Available")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
}

fileprivate struct GraphsView: View {
    let workouts: [Writers.CompletedWorkout]
    let components: CalendarComponents
    
    var body: some View {
        Group {
            if workouts.isEmpty { empty }
            else { graphs }
        }
    }
    
    var empty: some View {
        EmptyCard(
            title: "No Data Available",
            description: "No workouts were completed during this month"
        )
        .padding(.horizontal, PADDING_INLINE)
    }
    
    var graphs: some View {
        ScrollView(.horizontal) {
            LazyHStack {
                VolumeGraph(workouts: workouts)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
                TimeGraph(workouts: workouts)
                    .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
                BodyPartGraph(components: components)
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
    let workouts: [Writers.CompletedWorkout]
    
    var body: some View {
        VStack {
            SectionTitle("Past Workouts")
            LazyVStack {
                ForEach(workouts) { workout in
                    CompletedWorkoutRowView(workout: workout)
                        .contentShape(Rectangle())
                        .onTapGesture { Router.shared.push(CompletedWorkoutRoute(workout: workout)) }
                }
            }
        }
    }
}

fileprivate struct CompletedWorkoutRowView: View {
    @EnvironmentObject private var store: DataStore
    let workout: Writers.CompletedWorkout
    
    var body: some View {
        Card {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.fromHex(workout.color))
                    .frame(width: 8, height: 48)
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .fontWeight(.semibold)
                    Text(workout.wrappers.flattened().getBodyParts())
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    HStack(spacing: 4) {
                        Text(workout.startedAt.formatted(date: .numeric, time: .omitted))
                        Text("•")
                        Text("\(workout.getMinutes()) min")
                        Text("•")
                        Text("\(workout.wrappers.flattened().getVolume()) sets")
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
                Spacer()
                Menu("", systemImage: "ellipsis.circle") {
                    Button(role: .destructive) { handleDelete() } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func handleDelete() {
        do {
            try store.deleteCompletedWorkout(workout)
        } catch {
            Router.shared.toast("Error deleting \(workout.name)", type: .error)
        }
    }
}

#Preview {
    HistoryScreen()
        .mockNavigation
        .mockEnvironment
}
