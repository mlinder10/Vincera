//
//  CreateExercisePage.swift
//  Vincera
//
//  Created by Matt Linder on 10/27/24.
//

import SwiftUI

struct CreateExercisePage: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var eStore: ExerciseStore
  @State private var name = ""
  @State private var description = ""
  @State private var bodyPart: BodyPart = .chest
  @State private var primaryGroup: MuscleGroup = .pecs
  @State private var equipmentType: EquipmentType = .barbell
  @State private var exerciseType: ExerciseType = .compound
  
  var body: some View {
    Form {
      TextField("Name", text: $name)
      TextField("Description", text: $description, axis: .vertical)
        .lineLimit(3, reservesSpace: true)
      Picker("Body Part", selection: $bodyPart) {
        ForEach(BodyPart.allCases) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      Picker("Muscle Group", selection: $primaryGroup) {
        ForEach(MuscleGroup.allCases) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      Picker("Equipment Type", selection: $equipmentType) {
        ForEach(EquipmentType.allCases) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
      Picker("Exercise Type", selection: $exerciseType) {
        ForEach(ExerciseType.allCases) {
          Text($0.rawValue.capitalized).tag($0)
        }
      }
    }
    .scrollDismissesKeyboard(.interactively)
    .navigationTitle("Create Exercise")
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
        Button {
          router.showDialog("Confirm", action: handleCreate)
        } label: {
          Text("Create")
        }
      }
    }
  }
  
  func handleCreate() {
    do {
      try eStore.createExercise(
        ListExercise(
          id: UUID().uuidString,
          name: name,
          description: description,
          directions: [],
          cues: [],
          image: "",
          videoId: "",
          bodyPart: bodyPart.rawValue,
          primaryGroup: primaryGroup.rawValue,
          secondaryGroups: [],
          exerciseType: exerciseType.rawValue,
          equipmentType: equipmentType.rawValue,
          repsLow: 0,
          repsHigh: 0
        )
      )
      router.goBack()
    } catch {
      print(error.localizedDescription)
      router.notify(.danger, "Error saving exercise")
    }
  }
}

#Preview {
  CreateExercisePage()
}
