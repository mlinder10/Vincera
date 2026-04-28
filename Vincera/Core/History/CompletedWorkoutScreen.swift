//
//  CompletedWorkoutScreen.swift
//  Vincera
//
//  Created by Matt Linder on 10/27/24.
//

import SwiftUI

struct CompletedWorkoutScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var isEditing = false // Should not be replaced with \.editMode
    @ObservedObject var workout: Builder.CompletedWorkout
    private var previous: [Writers.Exercise] {
        store.getPreviousExercises(
            listIds: workout
                .wrappers
                .flattened()
                .map({ $0.listId }),
            workoutId: workout.id)
    }
    
    init(workout: Writers.CompletedWorkout) {
        self.workout = workout.toBuilder()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                if isEditing {
                    TextField("Workout Name", text: $workout.name)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                } else {
                    Text(workout.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                }
                
                if isEditing {
                    TextField("Notes", text: $workout.notes, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()
                        .lineLimit(3, reservesSpace: true)
                } else {
                    Text(workout.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                if isEditing {
                    editDateView
                } else {
                    dateView
                }
                
                metadataView
                
                exercisesView
                
                BrandButton("Add Exercise") {
                    Router.shared.push(
                        ExerciseListRoute(
                            hidden: workout.wrappers.flattened().map({ $0.listId }),
                            replacementId: nil,
                            onTap: nil,
                            onAdd: { workout.wrappers.addExercises($0); Router.shared.pop() }
                        )
                    )
                }
                .secondary
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit", action: handleEditToggle)
            }
        }
    }
    
    private var dateView: some View {
        HStack {
            Text(workout.startedAt.formatted())
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
            Text(workout.endedAt.formatted())
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
    
    private var editDateView: some View {
        VStack {
            DatePicker("Start Time", selection: $workout.startedAt)
            DatePicker("End Time", selection: $workout.endedAt)
        }
    }
    
    private var metadataView: some View {
        HStack {
            VStack {
                Text("Average RPE")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(workout.wrappers.getAverageRPE().formatted(.number.precision(.fractionLength(0...1))))
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            VStack {
                Text("Total Volume")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(workout.wrappers.flattened().getVolume().formatted())
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical)
    }
    
    private var exercisesView: some View {
        DraggableForEach(
            $workout.wrappers,
            withDividers: true,
            disabled: !isEditing
        ) { wrapper in
            ExerciseView(
                wrapper: wrapper,
                previous: previous,
                showsRpe: true,
                disabled: !isEditing,
                removeWrapper: handleRemoveWrapper
            ) {
                MenuOptions(
                    wrapper: wrapper,
                    hidden: workout.wrappers.flattened().map({ $0.listId }),
                    removeExercise: { workout.wrappers.removeAll(where: { $0.id == wrapper.id }) }
                )
            }
        }
    }
    
    private func handleRemoveWrapper(_ wrapper: Builder.Wrapper) {
        workout.wrappers.removeAll(where: { $0.id == wrapper.id })
    }
    
    private func handleEditToggle() {
        if !isEditing {
            isEditing = true
            return
        }
        do {
            if workout.name.isEmpty { workout.name = "Empty" }
            try store.editCompletedWorkout(workout.toWriter())
            isEditing = false
        } catch {
            Router.shared.toast("Error saving changes", type: .error)
        }
    }
}
