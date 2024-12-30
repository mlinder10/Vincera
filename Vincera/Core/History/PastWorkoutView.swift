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
  private var previous: [Exercise] { wStore.getPreviousExercises(listIds: workout.exercises.flattened().map({ $0.listId }), workoutId: workout.id)}
  
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
  
  func handleEditToggle() {
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
