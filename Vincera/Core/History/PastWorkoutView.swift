//
//  PastWorkoutView.swift
//  Vincera
//
//  Created by Matt Linder on 10/27/24.
//

import SwiftUI

struct PastWorkoutView: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var isEditing = false // Should not be replaced with \.editMode
    @Binding var workout: Workout
    private var previous: [Exercise] {
        wStore.getPreviousExercises(
            listIds: workout
                .exercises
                .flattened()
                .map({ $0.listId }),
            workoutId: workout.id)
    }
    
    var body: some View {
        List {
            VStack {
                if isEditing {
                    TextField("Workout Name", text: $workout.name)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                } else {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            .plainListStyle
            VStack {
                if isEditing { editDateView }
                else { dateView }
                metadataView
            }
            .plainListStyle
            ForEach($workout.exercises, id: \.self) { $wrapper in
                VStack(spacing: 24) {
                    if isEditing {
                        ExerciseView(
                            exercises: $wrapper,
                            previous: previous,
                            showsRpe: true,
                            removeWrapper: { workout.exercises.remove($0) }) {
                                MenuOptions(
                                    wrapper: $wrapper,
                                    hidden: workout.exercises.flattened().map({ $0.listId }),
                                    removeExercise: { workout.exercises.remove(wrapper) }
                                )
                            }
                    } else {
                        ImmutableExerciseView(exercises: wrapper, previous: previous, showsRpe: true) { EmptyView() }
                    }
                    Divider()
                }
                .padding(.bottom, 24)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Rectangle().fill(.clear))
            }
            .onMove{ workout.exercises.move(from: $0, to: $1) }
        }
        .listRowSpacing(4)
        .listRowSeparator(.visible)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { handleEditToggle() } label: {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
    }
    
    private var dateView: some View {
        HStack {
            Text(workout.start.formatted())
                .foregroundStyle(.secondary)
                .font(.caption)
            Rectangle()
                .fill(Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
            Text(workout.getMinutes().secondFormatted)
            Rectangle()
                .fill(Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 1)
            Text(workout.end?.formatted() ?? "")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
    
    private var editDateView: some View {
        VStack {
            DatePicker("Start Time", selection: $workout.start)
            DatePicker(
                "End Time",
                selection: Binding(
                    get: { workout.end ?? workout.start },
                    set: { newEnd in workout.end = newEnd }
                )
            )
        }
    }
    
    private var metadataView: some View {
        HStack {
            VStack {
                Text("Average RPE")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(workout.exercises.getAverageRpe().formatted())
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            VStack {
                Text("Total Volume")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(workout.exercises.getVolume().formatted())
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
    }
    
    private func handleEditToggle() {
        if !isEditing {
            isEditing = true
            return
        }
        do {
            if workout.name.isEmpty { workout.name = "Empty" }
            try wStore.editWorkout(workout)
            isEditing = false
        } catch {
            router.notify(.danger, "Error saving changes")
        }
    }
}
