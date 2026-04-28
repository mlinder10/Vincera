//
//  WorkoutEditor.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct WorkoutEditor: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var builder: Builder.Workout
    private var previous: [Writers.Exercise] {
        store.getPreviousExercises(
            listIds: builder.wrappers
                .flattened()
                .map({ $0.listId })
        )
    }
    
    init(_ workout: Writers.Workout?) {
        let wrappedValue = workout?.toBuilder() ?? Builder.Workout.new()
        self._builder = StateObject(wrappedValue: wrappedValue)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                VStack {
                    TextField("Name", text: $builder.name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Description", text: $builder.description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                    ColorPicker("Color", selection: $builder.color)
                }
                
                Divider()
                
                DraggableForEach($builder.wrappers, withDividers: true) { wrapper in
                    ExerciseView(
                        wrapper: wrapper,
                        previous: previous,
                        removeWrapper: { wrapper in
                            builder.wrappers.removeAll(where: { $0.id == wrapper.id })
                        }) {
                            MenuOptions(
                                wrapper: wrapper,
                                hidden: builder.wrappers.flattened().map({ $0.listId }),
                                removeExercise: {
                                    builder.wrappers.removeAll(where: { $0.id == wrapper.id })
                                }
                            )
                        }
                }
                
                BrandButton("Add Exercise") {
                    Router.shared.push(
                        ExerciseListRoute(
                            hidden: builder.wrappers.flattened().map({ $0.listId }),
                            replacementId: nil,
                            onTap: nil,
                            onAdd: {
                                builder.wrappers.addExercises($0)
                                Router.shared.pop()
                            }
                        )
                    )
                }
                .secondary
                
                BrandButton("Save", action: handleSave)
                    .primary
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandButton("Discard", role: .destructive, action: Router.shared.pop)
                    .withAlert(title: "Discard")
            }
        }
    }
    
    func handleSave() {
        do {
            if builder.name.count == 0 { builder.name = "Untitled Workout" }
            if store.workouts.contains(where: { $0.id == builder.id }) {
                try store.editWorkout(builder.toWriter())
            } else {
                try store.createWorkout(builder.toWriter())
            }
            Router.shared.toast("Saved \(builder.name)", type: .success)
            Router.shared.pop()
        } catch {
            Router.shared.toast("Error saving \(builder.name)", type: .error)
        }
    }
}
