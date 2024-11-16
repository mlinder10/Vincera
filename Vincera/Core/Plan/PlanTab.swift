//
//  PlanTab.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct PlanTab: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  @EnvironmentObject private var dStore: DayStore
  
  var body: some View {
    ScrollView {
      VStack {
        if let split = sStore.current {
          SplitCell(split: Binding(get: { split }, set: { sStore.current = $0 }), isListItem: false)
            .padding(.vertical)
        } else {
          EmptySplitView()
        }
        buttons
          .padding(.top)
        LabeledDivider(label: "Workouts")
          .padding(.vertical, 16)
        days
      }
      .padding(.horizontal)
    }
    .navigationTitle("Plan")
  }
  
  var buttons: some View {
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
  
  var days: some View {
    LazyVStack {
      Button { router.goTo(.dayEditor(nil)) } label: {
        HStack {
          RoundedRectangle(cornerRadius: 8)
            .fill(.accent)
            .frame(width: 40, height: 40)
            .overlay {
              Image(systemName: "plus")
                .foregroundStyle(Color.background)
            }
          Text("Create Individual Workout")
          Spacer()
        }
      }
      .foregroundStyle(.primary)
      ForEach(dStore.days) { day in
        Divider().padding(8)
        DayCell(day: day)
      }
    }
  }
}

fileprivate struct EmptySplitView: View {
  
  var body: some View {
    VStack(spacing: 12) {
      Text("Craft Your Plan")
        .fontWeight(.semibold)
      Text("Pick from a list of our built in splits or create your own")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    .padding(.top, 140)
  }
}

fileprivate struct DayCell: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var dStore: DayStore
  @EnvironmentObject private var eStore: ExerciseStore
  let day: Day
  
  var body: some View {
    Button { router.goTo(.dayEditor(day)) } label: {
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
      try dStore.deleteDay(day)
    } catch {
      router.notify(.danger, "Error deleting \(day.name)")
    }
  }
}

#Preview {
    PlanTab()
}
