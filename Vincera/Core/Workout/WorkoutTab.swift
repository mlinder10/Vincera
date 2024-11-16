//
//  WorkoutView.swift
//  Weights
//
//  Created by Matt Linder on 8/7/24.
//

import SwiftUI

struct WorkoutTab: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  @EnvironmentObject private var wStore: WorkoutStore
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        if let split = sStore.current {
          InfiniteCarousel(
            data: split.days,
            initialTabIndex: (sStore.meta.dayIndex ?? 0) + 1,
            height: 200,
            onTabChange: { sStore.setDayIndex($0) }) {
              WorkoutCell(split: split, day: $0, startWorkout: handleStartWorkout)
            }
        } else {
          EmptySplitView().padding(.horizontal)
        }
        LabeledDivider(label: "Workouts").padding(.horizontal)
        DaysView() { handleStartWorkout($0) }.padding(.horizontal)
      }
    }
    .navigationTitle("Workout")
  }
  
  func handleStartWorkout(_ day: Day? = nil) {
    do {
      try wStore.startWorkout(day)
      router.isShowingActiveWorkout = true
    } catch {
      Haptics.shared.notify(.warning)
    }
  }
}

fileprivate struct WorkoutCell: View {
  @EnvironmentObject private var eStore: ExerciseStore
  let split: Split
  let day: Day
  let startWorkout: (Day?) -> Void
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 16) {
        RoundedRectangle(cornerRadius: 12).fill(Color.fromHex(day.color)).frame(width: 48, height: 48)
        VStack(alignment: .leading) {
          HStack(spacing: 0) {
            Text(day.name)
              .fontWeight(.semibold)
            Text(" • \(split.name)")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
          Text(day.exercises.getBodyParts(eStore))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      }
      Divider().padding(.vertical, 4)
      WorkoutCellExercises(day: day)
      Spacer()
    }
    .padding()
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 200)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(.regularMaterial)
    )
    .onTapGesture { startWorkout(day) }
  }
}

fileprivate struct WorkoutCellExercises: View {
  @EnvironmentObject private var eStore: ExerciseStore
  let day: Day
  
  var body: some View {
    VStack(alignment: .leading) {
      if day.exercises.count <= 5 { fitting }
      else { overflow }
    }
  }
  
  var fitting: some View {
    ForEach(day.exercises, id: \.self) { wrapper in
      if let first = eStore.getExercise(wrapper.first?.listId ?? "") {
        Text(first.name + (wrapper.count == 1 ? "" : "+"))
      }
    }
    .font(.subheadline)
  }
  
  var overflow: some View {
    VStack(alignment: .leading) {
      ForEach(0..<4, id: \.self) { index in
        if let first = eStore.getExercise(day.exercises[index].first?.listId ?? "") {
          Text(first.name + (day.exercises[index].count == 1 ? "" : "+"))
        }
      }
      Text("...")
        .font(.subheadline)
    }
  }
}

fileprivate struct EmptySplitView: View {
  @EnvironmentObject private var router: Router
  
  var body: some View {
    VStack(spacing: 12) {
      Text("Select a Split to Get Started")
        .fontWeight(.semibold)
      Text("You can create a split or choose one from a list of pre-existing splits.")
        .foregroundStyle(.secondary)
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
      HStack {
        Button { router.goTo(.splitList) } label: {
          Text("View Splits")
            .frame(maxWidth: .infinity)
        }
        .bordered
        Button { router.goTo(.splitEditor(nil)) } label: {
          Text("Create Split")
            .frame(maxWidth: .infinity)
        }
        .borderedProminent
      }
    }
    .padding(.top, 140)
  }
}


fileprivate struct DaysView: View {
  @EnvironmentObject private var dStore: DayStore
  @EnvironmentObject private var eStore: ExerciseStore
  private let columns = [GridItem(), GridItem()]
  let startWorkout: (Day?) -> Void
  
  var body: some View {
    LazyVStack {
      Button { startWorkout(nil) } label: {
        HStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(.accent)
            .frame(width: 40, height: 40)
            .overlay {
              Image(systemName: "bolt.fill")
                .foregroundStyle(Color.background)
            }
          Text("Start Empty Workout")
          Spacer()
        }
      }
      .foregroundStyle(.primary)
      ForEach(dStore.days) { day in
        Divider().padding(8)
        DayCell(day: day, startWorkout: startWorkout)
      }
    }
  }
}

fileprivate struct DayCell: View {
  @EnvironmentObject private var eStore: ExerciseStore
  let day: Day
  let startWorkout: (Day?) -> Void
  
  var body: some View {
    Button { startWorkout(day) } label: {
      HStack {
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.fromHex(day.color))
          .frame(width: 40, height: 40)
        VStack(alignment: .leading) {
          Text(day.name)
          Text(day.exercises.getBodyParts(eStore))
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Image(systemName: "chevron.right")
          .font(.caption)
          .foregroundStyle(.secondary)
      }
      .padding(.trailing)
    }
    .foregroundStyle(.primary)
  }
}
