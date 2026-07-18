//
//  CreateExerciseScreen.swift
//  Vincera
//
//  Created by Matt Linder on 10/27/24.
//

import SwiftUI

private struct ExerciseInputs {
    var name = ""
    var bodyPart: BodyPart = .chest
    var primaryGroup: MuscleGroup = .pecs
    var equipmentType: EquipmentType = .barbell
    var exerciseType: ExerciseType = .compound
    var unitsOne: ExerciseUnit = .weight
    var unitsTwo: ExerciseUnit? = .reps
}

struct CreateExerciseScreen: View {
    @State private var inputs = ExerciseInputs()
    
    var body: some View {
        TabView {
            CreateExerciseForm(inputs: $inputs)
            CreateExercisePreview(inputs: inputs)
                .padding(.horizontal, PADDING_INLINE)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Create Exercise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandButton("Discard", role: .destructive, action: Router.shared.pop)
                .withAlert(title: "Discard")
            }
            ToolbarItem(placement: .topBarTrailing) {
                BrandButton("Create", action: handleCreate)
                    .withAlert(title: "Confirm")
            }
        }
    }
    
    private func handleCreate() {
        do {
            try ExerciseList.shared.createExercise(
                ListExercise(
                    id: CUSTOM_EXERCISE_PREFIX + UUID().uuidString,
                    name: inputs.name,
                    description: "",
                    directions: [],
                    cues: [],
                    image: "",
                    videoUrl: "",
                    bodyPart: inputs.bodyPart.rawValue,
                    primaryGroup: inputs.primaryGroup.rawValue,
                    secondaryGroups: [],
                    exerciseType: inputs.exerciseType.rawValue,
                    equipmentType: inputs.equipmentType.rawValue,
                    unitsOne: inputs.unitsOne,
                    unitsTwo: inputs.unitsTwo ?? inputs.unitsOne,
                    repsLow: 0,
                    repsHigh: 0,
                    stimulus: 1,
                    fatigue: 1
                )
            )
            Router.shared.pop()
        } catch {
            print(error.localizedDescription)
            Router.shared.toast("Error saving exercise", type: .error)
        }
    }
}

private struct CreateExerciseForm: View {
    @Binding var inputs: ExerciseInputs
    
    var body: some View {
        Form {
            TextField("Name", text: $inputs.name)
            
            Picker("Body Part", selection: $inputs.bodyPart) {
                ForEach(BodyPart.allCases) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            Picker("Muscle Group", selection: $inputs.primaryGroup) {
                ForEach(inputs.bodyPart.applicableMuscleGroups()) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            Picker("Equipment Type", selection: $inputs.equipmentType) {
                ForEach(EquipmentType.allCases) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            Picker("Exercise Type", selection: $inputs.exerciseType) {
                ForEach(ExerciseType.allCases) {
                    Text($0.rawValue.capitalized).tag($0)
                }
            }
            Picker("Unit One", selection: $inputs.unitsOne) {
                ForEach(ExerciseUnit.allCases) {
                    Text($0.rawValue).tag($0)
                }
            }
            Picker("Unit Two", selection: $inputs.unitsTwo) {
                Text("None").tag(nil as ExerciseUnit?)
                ForEach(ExerciseUnit.allCases) { unit in
                    Text(unit.rawValue).tag(unit as ExerciseUnit?)
                }
            }
        }
        .onChange(of: inputs.bodyPart) { inputs.primaryGroup = $1.applicableMuscleGroups().first! }
    }
}

private struct CreateExercisePreview: View {
    let inputs: ExerciseInputs
    private let columns: [GridItem]
    @State private var setType: SetType = .normal
    @State private var valueOne: Double?
    @State private var valueTwo: Double?
    @State private var rpe: Int = 5
    
    init(inputs: ExerciseInputs) {
        self.inputs = inputs
        if inputs.unitsTwo != nil {
            self.columns = [GridItem(.fixed(32)), GridItem(), GridItem(), GridItem()]
        } else {
            self.columns = [GridItem(.fixed(32)), GridItem(), GridItem()]
        }
    }
    
    var body: some View {
        VStack {
            SectionTitle("Exercise Preview")
            Card {
                VStack {
                    HStack {
                        Text(inputs.name)
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.accent)
                    }
                    LazyVGrid(columns: columns) {
                        Text("Set")
                        Text("Previous")
                        Text(inputs.unitsOne.rawValue)
                        if let unitsTwo = inputs.unitsTwo {
                            Text(unitsTwo.rawValue)
                        }
                        
                        SetTypeView(type: $setType, index: 1)
                        Text("-").foregroundStyle(.secondary)
                        NumberField("-", num: $valueOne, validate: false)
                        if inputs.unitsTwo != nil {
                            NumberField("-", num: $valueTwo, validate: false)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CreateExerciseScreen()
        .mockNavigation
}
