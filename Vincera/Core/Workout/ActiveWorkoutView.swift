//
//  ActiveWorkoutView.swift
//  Weights
//
//  Created by Matt Linder on 8/10/24.
//

import SwiftUI

enum TimerDuration: Double, CaseIterable, Identifiable {
  var id: Self { self }
  
  case oneMin = 60
  case twoMin = 120
  case threeMin = 180
  case fiveMin = 300
  
  var label: String {
    switch self {
    case .oneMin:
      "One"
    case .twoMin:
      "Two"
    case .threeMin:
      "Three"
    case .fiveMin:
      "Five"
    }
  }
}

struct TimerData {
  var show: Bool
  var duration: Double
  var start: Date? = nil
  
  init() {
    self.show = false
    self.duration = TimerDuration.oneMin.rawValue
    self.start = nil
  }
}

struct ActiveWorkoutView: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  @EnvironmentObject private var wStore: WorkoutStore
  @Binding var workout: Workout
  @State private var validate = false
  @State private var timer = TimerData()
  private var previous: [Exercise] { wStore.getPreviousExercises(listIds: workout.exercises.flattened().map({ $0.listId })) }
  
  var body: some View {
    List {
      exercises
      addExerciseButton
      saveWorkoutButton
    }
    .listRowSpacing(4)
    .listRowSeparator(.visible)
    .scrollIndicators(.hidden)
    .scrollDismissesKeyboard(.interactively)
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
//        TimerView(start: workout.start)
        Button { timer.show = true } label: {
          Text("Timer")
        }
      }
    }
    .overlay {
      if timer.show {
        RestTimerView(data: $timer)
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

struct RestTimerView: View {
  @Binding var data: TimerData
  
  var body: some View {
    ZStack {
      Color.black.opacity(0.3)
        .onTapGesture { data.show = false }
      VStack {
        Text("test")
        VStack {
          LazyVGrid(columns: Array(repeating: GridItem(), count: 2)) {
            ForEach(TimerDuration.allCases) { dur in
              Button { data.duration = dur.rawValue } label: {
                Text(dur.label)
                  .frame(maxWidth: .infinity)
              }
              .borderedProminent
            }
          }
          Button {} label: {
            Text("Custom Value")
              .frame(maxWidth: .infinity)
          }
          .borderedProminent
        }
        .font(.caption)
      }
      .padding()
      .frame(maxWidth: 300)
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.background)
      )
    }
    .ignoresSafeArea()
  }
}
