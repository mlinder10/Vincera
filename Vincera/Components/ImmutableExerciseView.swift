//
//  ImmutableExerciseView.swift
//  Vincera
//
//  Created by Matt Linder on 10/28/24.
//

import SwiftUI

struct ImmutableExerciseView<T: View>: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var eStore: ExerciseStore
  @State private var scrollItemId: Exercise.ID? = nil
  private var scrollIndex: Int? { exercises.firstIndex(where: { $0.id == scrollItemId }) }
  private var currentExercise: Exercise? { scrollIndex == nil ? exercises.first : exercises[scrollIndex!] }
  let exercises: [Exercise] // input
  private var listExercises: [ListExercise] { exercises.map { eStore.getExercise($0.listId) ?? ListExercise.UNKNOWN } }
  let previous: [Exercise] // input
  var showsRpe: Bool = false // input
  var validate: Bool = false // input
  let menuItems: () -> T // input
  
  
  var body: some View {
    VStack(spacing: 8) {
      upper
      exercisesScroll
      if showsRpe { rpe }
    }
  }
  
  var upper: some View {
    HStack {
      Text(eStore.getExercise(currentExercise?.listId ?? "")?.name ?? "")
        .fontWeight(.semibold)
      Spacer()
      Menu {
        Button { handleOpenExercisePage() } label: {
          Label("Learn", systemImage: "book")
        }
        menuItems()
      } label: {
        Image(systemName: "ellipsis.circle")
      }
    }
  }
  
  var exercisesScroll: some View {
    Group {
      if exercises.count > 1 { TabIndexView(index: scrollIndex, total: exercises.count) }
      ScrollView(.horizontal) {
        HStack {
          ForEach(exercises) { ex in
            let p = previous.first(where: { $0.listId == ex.listId })
            SetsView(exercise: ex, previous: p, validate: validate)
              .containerRelativeFrame(.horizontal, count: 1, spacing: 10.0)
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $scrollItemId)
      .scrollTargetBehavior(.paging)
      .scrollIndicators(.hidden)
    }
  }
  
  var rpe: some View {
    HStack {
      Text("RPE")
      Spacer()
      Text(currentExercise?.rpe.formatted() ?? "-")
    }
    .padding(.horizontal)
  }
  
  func handleOpenExercisePage() {
    guard let currentExercise, let exercise = eStore.getExercise(currentExercise.listId) else { return }
    router.goTo(.exercisePage(exercise))
  }
}

fileprivate struct SetsView: View {
  @EnvironmentObject private var wStore: WorkoutStore
  @EnvironmentObject private var eStore: ExerciseStore
  let exercise: Exercise
  let previous: Exercise?
  private let columns = [GridItem(.fixed(30)), GridItem(), GridItem(), GridItem()]
  let validate: Bool
  
  var body: some View {
    LazyVGrid(columns: columns, spacing: 8) {
      Text("Set")
      Text("Previous")
      Text(exercise.unitOne.rawValue)
      Text(exercise.unitTwo.rawValue)
      ForEach(Array(exercise.sets.enumerated()), id: \.offset) { (index, set) in
        SetTypeView(type: set.type, index: index + 1)
        if let vals = getPreviousValues(index) {
          let isSelected = hasSelectedPrevious(vals, index: index)
          Button {
            if isSelected {
              Haptics.shared.notify(.warning)
            } else {
              exercise.sets[index].valueOne = vals.0
              exercise.sets[index].valueTwo = vals.1
            }
          } label: {
            Text("\(vals.0.formatted())x\(vals.1.formatted())")
          }
          .foregroundStyle(.secondary)
        } else {
          Text("-")
            .foregroundStyle(.secondary)
        }
        Text(set.valueOne?.formatted() ?? "-")
          .background(
            RoundedRectangle(cornerRadius: 4)
              .fill(.regularMaterial)
              .frame(width: 60, height: 20)
          )
        Text(set.valueTwo?.formatted() ?? "-")
          .background(
            RoundedRectangle(cornerRadius: 4)
              .fill(.regularMaterial)
              .frame(width: 60, height: 20)
          )
      }
    }
  }
  
  func getPreviousValues(_ index: Int) -> (Double, Double)? {
    guard let previous else { return nil }
    guard previous.sets.count > index else { return nil }
    guard let valueOne = previous.sets[index].valueOne,
          let valueTwo = previous.sets[index].valueTwo else { return nil }
    return (valueOne, valueTwo)
  }
  
  func hasSelectedPrevious(_ vals: (Double, Double)?, index: Int) -> Bool {
    guard let vals, exercise.sets.count > index else { return false }
    return exercise.sets[index].valueOne == vals.0 && exercise.sets[index].valueTwo == vals.1
  }
}

fileprivate struct SetTypeView: View {
  let type: SetType
  let index: Int
  private var letter: String {
    return switch type {
    case .normal: "N"
    case .myo: "M"
    case .drop: "D"
    case .warmup: "W"
    case .cooldown: "C"
    }
  }
  private var color: Color {
    return switch type {
    case .normal: .gray
    case .myo: .red
    case .drop: .purple
    case .warmup: .orange
    case .cooldown: .blue
    }
  }
  
  var body: some View {
    Text(type == .normal ? "\(index)" : letter)
      .background(
        RoundedRectangle(cornerRadius: 6)
          .fill(color)
          .frame(width: 24, height: 24)
      )
  }
}

