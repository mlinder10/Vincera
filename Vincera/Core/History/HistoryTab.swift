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
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button { router.goTo(.settings) } label: {
          Image(systemName: "gearshape")
        }
      }
    }
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
      LazyVGrid(columns: columns) {
        ForEach(wStore.getPrs(), id: \.0) { pr in
          PRCell(pr: pr)
        }
      }
    }
  }
}

fileprivate struct PRCell: View {
  @EnvironmentObject private var eStore: ExerciseStore
  let pr: (PRTracker, Exercise?)
  var exercise: ListExercise { eStore.getExercise(pr.0.listId) ?? ListExercise.UNKNOWN }
  
  var body: some View {
    VStack(spacing: 6) {
      pr.0.type.label
        .fontWeight(.semibold)
      Text(exercise.name)
        .font(.caption)
      if let exercise = pr.1, let value = exercise.maxValue(for: pr.0.type) {
        Text(value.formatted())
          .font(.title)
          .fontWeight(.bold)
      } else {
        Text("No Data Avaliable")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
    }
    .padding(.vertical)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
  }
}

fileprivate struct GraphsView: View {
  @State private var timeframe: Timeframe = .week
  
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
      ScrollView(.horizontal) {
        LazyHStack {
          VolumeGraph(timeframe: timeframe)
            .containerRelativeFrame(.horizontal, count: 1, spacing: 24)
          TimeGraph(timeframe: timeframe)
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
}

fileprivate struct WorkoutsView: View {
  @EnvironmentObject private var wStore: WorkoutStore
  @State private var timeframe: Timeframe = .week
  @State private var search = ""
  var workouts: [Workout] { wStore.getFiltered(search, timeframe) }
  
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
