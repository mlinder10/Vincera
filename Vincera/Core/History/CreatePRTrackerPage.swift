//
//  CreatePRTrackerPage.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI

private let MAX_TRACKER_COUNT = 8

struct CreatePRTrackerPage: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var wStore: WorkoutStore
  @State private var toAdd = [PRTracker]()
  
  var body: some View {
    VStack {
      ScrollView {
        LazyVGrid(columns: [GridItem(), GridItem()]) {
          ForEach($wStore.meta.prs) {
            TrackerCell(tracker: $0) { handleDelete($0, $1) }
          }
          ForEach($toAdd) {
            TrackerCell(tracker: $0) { handleDelete($0, $1) }
          }
        }
      }
      Button { handleSave() } label: {
        Text("Save")
          .frame(maxWidth: .infinity)
      }
      .borderedProminent
    }
    .padding()
    .navigationTitle("Track PR's")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(role: .destructive) {
          router.showDialog("Discard", role: .destructive, action: router.goBack)
        } label: {
          Text("Discard")
            .foregroundStyle(.red)
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button { handleAdd() } label: {
          HStack {
            Text("Add")
            Image(systemName: "plus.circle")
          }
        }
      }
    }
  }
  
  func handleAdd() {
    guard wStore.meta.prs.count + toAdd.count < MAX_TRACKER_COUNT else {
      router.notify(.warning, "Cannot track more than \(MAX_TRACKER_COUNT) PR's")
      return
    }
    router.goTo(
      .exerciseList(
        [],
        { toAdd.append(PRTracker(listId: $0.id, type: .reps)); router.goBack()},
        { _ in }
      )
    )
  }
  
  func handleSave() {
    var trackers = wStore.meta.prs
    trackers.append(contentsOf: toAdd)
    let uniqueTrackers = Array(Set(trackers))
    do {
      try wStore.saveAllTrackers(uniqueTrackers)
      router.goBack()
    } catch {
      router.notify(.danger, "Error saving changes")
    }
  }
  
  func handleDelete(_ tracker: PRTracker, _ exercise: ListExercise) {
    do {
      try wStore.deletePrTracker(tracker)
    } catch {
      router.notify(.danger, "Error removing \(exercise.name) tracker")
    }
  }
}

fileprivate struct TrackerCell: View {
  @EnvironmentObject private var wStore: WorkoutStore
  @EnvironmentObject private var eStore: ExerciseStore
  @Binding var tracker: PRTracker
  var exercise: ListExercise { eStore.getExercise(tracker.listId) ?? ListExercise.UNKNOWN }
  let handleDelete: (PRTracker, ListExercise) -> Void
  
  var body: some View {
    VStack {
      HStack {
        Menu {
          Picker(selection: $tracker.type, label: EmptyView()) {
            ForEach(ExerciseUnit.allCases) {
              Text($0.rawValue)
                .tag($0)
            }
          }
        } label: {
          tracker.type.label
        }
        Spacer()
        Menu {
          Button(role: .destructive) { handleDelete(tracker, exercise) } label: {
            Label("Delete", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
      Text(exercise.name)
        .multilineTextAlignment(.center)
        .font(.subheadline)
        .fontWeight(.semibold)
        .padding(.vertical)
      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(RoundedRectangle(cornerRadius: 16).fill(.regularMaterial))
  }
}


#Preview {
  CreatePRTrackerPage()
}
