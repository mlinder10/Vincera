//
//  ExerciseView.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct ExerciseView<T: View>: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var eStore: ExerciseStore
  @State private var scrollItemId: Exercise.ID? = nil
  private var scrollIndex: Int? { exercises.firstIndex(where: { $0.id == scrollItemId }) }
  private var currentExercise: Exercise? { scrollIndex == nil ? exercises.first : exercises[scrollIndex!] }
  @Binding var exercises: [Exercise] // input
  private var listExercises: [ListExercise] { exercises.map { eStore.getExercise($0.listId) ?? ListExercise.UNKNOWN } }
  let previous: [Exercise] // input
  var showsRpe: Bool = false // input
  var validate: Bool = false // input
  let removeWrapper: ([Exercise]) -> Void // input
  let menuItems: () -> T // input
  
  
  var body: some View {
    VStack(spacing: 8) {
      upper
      exercisesScroll
      buttons
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
          ForEach($exercises) { ex in
            let p = previous.first(where: { $0.listId == ex.listId.wrappedValue })
            SetsView(exercise: ex, previous: p, validate: validate)
              .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
          }
        }
        .scrollTargetLayout()
      }
      .scrollPosition(id: $scrollItemId)
      .scrollTargetBehavior(.viewAligned)
      .scrollIndicators(.hidden)
    }
  }
  
  var buttons: some View {
    HStack {
      Text("Delete Set")
        .font(.caption)
        .foregroundStyle(.red)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 6).fill(.regularMaterial))
        .onTapGesture { handleRemoveSet() }
      Text("Add Set")
        .font(.caption)
        .foregroundStyle(.accent)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 6).fill(.regularMaterial))
        .onTapGesture { handleAddSet() }
    }
  }
  
  var rpe: some View {
    HStack {
      HStack {
        Image(systemName: "info.circle.fill")
        Text("RPE")
      }
      .foregroundStyle(.accent)
      .onTapGesture {
        router.giveDetails(
          "gauge.open.with.lines.needle.33percent",
          "Rate of Perceived Exertion (RPE)",
          "RPE, or Rate of Perceived Exertion, is a scale used to measure the intensity of an exercise based on how difficult it feels. " +
          "RPE ranges from 1 to 10, with higher numbers indicating greater effort.")
      }
      Spacer()
      Picker("", selection: Binding(get: { exercises.getRpe() ?? 5 }, set: { exercises.setRpe($0) })) {
        ForEach(1...10, id: \.self) { num in
          Text("\(num)").tag(num)
        }
      }
      .pickerStyle(.palette)
    }
  }
  
  func handleOpenExercisePage() {
    guard let currentExercise, let exercise = eStore.getExercise(currentExercise.listId) else { return }
    router.goTo(.exercisePage(exercise))
  }
  
  func handleRemoveSet() {
    guard let exercise = currentExercise else { return }
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    if exercise.sets.count > 1 {
      exercise.removeSet()
      return
    }
    
    router.showDialog("Remove Exercise", role: .destructive) {
      if exercises.count == 1 { removeWrapper(exercises) }
      else { exercises.removeAll(where: { $0.id == exercise.id }) }
    }
  }
  
  func handleAddSet() { currentExercise?.addSet() }
}

fileprivate struct SetsView: View {
  @EnvironmentObject private var wStore: WorkoutStore
  @EnvironmentObject private var eStore: ExerciseStore
  @Binding var exercise: Exercise
  private let columns = [GridItem(.fixed(30)), GridItem(), GridItem(), GridItem(), GridItem(.fixed(20))]
  let previous: Exercise?
  let validate: Bool
  
  var body: some View {
    LazyVGrid(columns: columns) {
      Text("Set")
      Text("Previous")
      Text(exercise.unitOne.rawValue)
      Text(exercise.unitTwo.rawValue)
      Text("")
      ForEach(Array($exercise.sets.enumerated()), id: \.offset) { (index, set) in
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
          .foregroundStyle(isSelected ? .secondary : .primary)
        } else {
          Text("-")
            .foregroundStyle(.secondary)
        }
        NumberField("-", num: set.valueOne, validate: validate)
        NumberField("-", num: set.valueTwo, validate: validate)
        if index + 1 < exercise.sets.count {
          Button { exercise.fillDown(index) } label: {
            Image(systemName: "arrow.down")
          }
          .disabled(!exercise.canFillDown(index))
        }
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
  @Binding var type: SetType
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
    Menu {
      Picker(selection: $type) {
        ForEach(SetType.allCases) { type in
          Text(type.rawValue.capitalized)
            .tag(type)
        }
      } label: { EmptyView() }
    } label: {
      Text(type == .normal ? "\(index)" : letter)
        .background(
          RoundedRectangle(cornerRadius: 6)
            .fill(color)
            .frame(width: 24, height: 24)
        )
    }
    .foregroundStyle(.primary)
  }
}

struct TabIndexView: View {
  let index: Int?
  let total: Int
  
  var body: some View {
    HStack {
      ForEach(0..<total, id: \.self) { tab in
        Rectangle()
          .fill(isCurrentTab(tab) ? .accent : .backgroundSecondary)
          .frame(maxWidth: .infinity)
          .frame(height: isCurrentTab(tab) ? 4 : 2)
      }
    }
  }
  
  func isCurrentTab(_ tab: Int) -> Bool {
    if index == nil && tab == 0 { return true }
    return index == tab
  }
}

struct MenuOptions: View {
  @EnvironmentObject private var router: Router
  @Binding var wrapper: [Exercise]
  let hidden: [String]
  let removeExercise: () -> Void
  
  var body: some View {
    VStack {
      Button {
        router.goTo(.exerciseList(hidden, nil, { wrapper.superset($0); router.goBack() }))
      } label: {
        Label(wrapper.count == 1  ? "Superset" : "Giant Set", systemImage: "plus")
      }
      Button {
        router.goTo(.exerciseList(hidden, nil, { wrapper.replace($0); router.goBack() }))
      } label: {
        Label("Replace", systemImage: "arrow.left.arrow.right")
      }
      Button(role: .destructive) {
        removeExercise()
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }
}
