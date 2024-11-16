//
//  DayEditor.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct DayEditor: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var dStore: DayStore
  @EnvironmentObject private var eStore: ExerciseStore
  @EnvironmentObject private var wStore: WorkoutStore
  @State private var day: Day
  private var previous: [Exercise] { wStore.getPreviousExercises(listIds: day.exercises.flattened().map({ $0.listId })) }
  
  init(_ day: Day?) {
    self.day = day?.cloneWithUUID() ?? Day()
  }
  
  var body: some View {
    List {
      VStack {
        TextField("Name", text: $day.name)
          .textFieldStyle(.roundedBorder)
        TextField("Description", text: $day.description, axis: .vertical)
          .textFieldStyle(.roundedBorder)
          .lineLimit(3, reservesSpace: true)
        ColorPicker("Color", selection: Binding(get: { Color.fromHex(day.color) }, set: { day.color = $0.toHex() }))
      }
      .plainListStyle
      ForEach($day.exercises, id: \.self) { $wrapper in
        ExerciseView(
          exercises: $wrapper,
          previous: previous,
          removeWrapper: { day.exercises.remove($0) }) {
            MenuOptions(
              wrapper: $wrapper,
              hidden: day.exercises.flattened().map({ $0.listId }),
              removeExercise: { day.exercises.remove(wrapper)}
            )
          }
      }
      .onMove { day.exercises.move(from: $0, to: $1) }
      .plainListStyle
      Button {
        router.goTo(
          .exerciseList(
            day.exercises.flatMap({ $0.compactMap({ $0.listId }) }),
            nil,
            { day.exercises.addExercises($0); router.goBack() }
          )
        )
      } label: {
        Text("Add Exercise")
          .frame(maxWidth: .infinity)
      }
      .bordered
      .plainListStyle
      Button { handleSave() } label: {
        Text("Save")
          .frame(maxWidth: .infinity)
      }
      .borderedProminent
      .plainListStyle
    }
    .listRowSpacing(12)
    .scrollDismissesKeyboard(.interactively)
    .navigationTitle("Edit Workout")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button {
          router.showDialog("Discard", role: .destructive, action: router.goBack)
        } label: {
          Text("Discard")
            .foregroundStyle(.red)
        }
      }
    }
  }
  

  
  func handleSave() {
    do {
      if dStore.days.contains(where: { $0.id == day.id }) {
        try dStore.editDay(day)
      } else {
        try dStore.createDay(day)
      }
      router.notify(.success, "Saved \(day.name)")
      router.goBack()
    } catch {
      router.notify(.danger, "Error saving \(day.name)")
    }
  }
}
