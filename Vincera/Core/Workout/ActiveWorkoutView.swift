//
//  ActiveWorkoutView.swift
//  Weights
//
//  Created by Matt Linder on 8/10/24.
//

import SwiftUI

fileprivate let CIRCLE_SIZE: CGFloat = 164

struct ActiveWorkoutView: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  @EnvironmentObject private var wStore: WorkoutStore
  @Binding var workout: Workout
  @State private var validate = false
  private var previous: [Exercise] { wStore.getPreviousExercises(listIds: workout.exercises.flattened().map({ $0.listId })) }
  
  var body: some View {
    ZStack {
      List {
        exercises
        addExerciseButton
        saveWorkoutButton
      }
      .listRowSpacing(4)
      .listRowSeparator(.visible)
      .scrollIndicators(.hidden)
      .scrollDismissesKeyboard(.interactively)
      RestTimerView()
      .padding(.horizontal)
    }
    .navigationTitle(workout.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(role: .destructive) {
          router.showDialog("Cancel Workout", role: .destructive, action: handleCancelWorkout)
        } label: {
          Text("Cancel")
            .foregroundStyle(.red)
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        TimerView(start: workout.start)
      }
    }
  }
  
  var exercises: some View {
    ForEach($workout.exercises, id: \.self) { $wrapper in
      ExerciseView(
        exercises: $wrapper,
        previous: previous,
        showsRpe: true,
        validate: validate,
        removeWrapper: { workout.exercises.remove($0) }) {
          MenuOptions(
            wrapper: $wrapper,
            hidden: workout.exercises.flattened().map({ $0.listId }),
            removeExercise: { workout.exercises.remove(wrapper) }
          )
        }
        .padding(.vertical, 24)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Rectangle().fill(.clear))
        .listRowSeparator(.visible)
    }
    .onMove{ workout.exercises.move(from: $0, to: $1) }
  }
  
  var addExerciseButton: some View {
    Button {
      router.goTo(
        .exerciseList(
          workout.exercises.getListIds(),
          nil,
          { workout.exercises.addExercises($0); router.goBack() }
        )
      )
    } label: {
      Text("Add Exercise")
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .bordered
    .plainListStyle
  }
  
  var saveWorkoutButton: some View {
    Button { handleStartSave() } label: {
      Text("End Workout")
        .frame(maxWidth: .infinity, alignment: .center)
    }
    .borderedProminent
    .plainListStyle
  }
  
  func handleStartSave() {
    guard workout.isValid() else {
      validate = true
      router.showDialog("End With Empty Fields", role: .destructive) {
        workout.fillEmpty()
        handleEndWorkout()
      }
      return
    }
    router.showDialog("End Workout", action: handleEndWorkout)
  }
  
  func handleCancelWorkout() {
    router.isShowingActiveWorkout = false
    wStore.cancelWorkout()
  }
  
  func handleEndWorkout() {
    do {
      try wStore.endWorkout()
      router.isShowingActiveWorkout = false
      if sStore.day?.id == workout.dayId { try? sStore.nextDay() }
      router.goTo(.pastWorkout($wStore.workouts[wStore.workouts.count-1]))
    } catch {
      router.notify(.danger, "Error saving workout")
    }
  }
}


