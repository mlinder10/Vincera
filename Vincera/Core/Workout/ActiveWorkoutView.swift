//
//  ActiveWorkoutView.swift
//  Weights
//
//  Created by Matt Linder on 8/10/24.
//

import SwiftUI

fileprivate let CIRCLE_SIZE: CGFloat = 164

struct ActiveWorkoutView: View {
    @EnvironmentObject private var store: DataStore
    @ObservedObject var workout: Builder.ActiveWorkout
    @State private var validate = false
    @State private var previous = [Writers.Exercise]()
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    Section(header: headerTextFieldsView, content: {})
                    exercises
                    addExerciseButton
                    saveWorkoutButton
                }
                .padding(.horizontal)
                .padding(.bottom, 72)
            }
            .scrollDismissesKeyboard(.interactively)
            .padding(.bottom, 32)
            
            RestTimerView()
                .padding(.horizontal)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandButton("Cancel", role: .destructive, action: handleCancelWorkout)
                    .withAlert(title: "Cancel Workout")
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink { PlateCalculatorScreen() } label: {
                    Image(systemName: "plusminus")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                TimerView(start: workout.startedAt)
            }
        }
        .task(id: workout) {
            previous = store.getPreviousExercises(
                listIds: workout
                    .wrappers
                    .flattened()
                    .map({ $0.listId })
            )
        }
    }
    
    @ViewBuilder
    private var headerTextFieldsView: some View {
        VStack {
            TextField("Name", text: $workout.name)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            TextField("Notes", text: $workout.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3, reservesSpace: true)
                .autocorrectionDisabled()
        }
    }
    
    @ViewBuilder
    private var exercises: some View {
        DraggableForEach($workout.wrappers, withDividers: true) { wrapper in
            ExerciseView(
                wrapper: wrapper,
                previous: previous,
                hiddenIds: workout.wrappers.flattened().map({ $0.listId }),
                showsRpe: true,
                validate: validate,
                removeWrapper: { wrapper in
                    workout.wrappers.removeAll(where: { $0.id == wrapper.id })
                })
                .contentShape(Rectangle())
                .padding(.vertical, 24)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Rectangle().fill(.clear))
                .listRowSeparator(.visible)
        }
    }
    
    @ViewBuilder
    private var addExerciseButton: some View {
        BrandButton("Add Exercise") {
            Router.shared.push(
                ExerciseListRoute(
                    hidden: workout.wrappers.flattened().map({ $0.listId }),
                    replacementId: nil,
                    onTap: nil,
                    onAdd: { workout.wrappers.addExercises($0); Router.shared.pop() }
                )
            )
        }
        .secondary
    }
    
    @ViewBuilder
    private var saveWorkoutButton: some View {
        BrandButton("End Workout") {
            Keyboard.dismiss()
            
            guard workout.isValid() else {
                validate = true
                return
            }
            handleEndWorkout()
        }
        .withAlert(title: "End Workout")
        .primary
    }
    
    private func handleCancelWorkout() {
        Router.shared.showWorkout = false
        store.cancelWorkout()
    }
    
    private func handleEndWorkout() {
        do {
            Router.shared.showWorkout = false
            try store.endWorkout()
            
            if store.currentDay?.id == workout.dayId { try? store.nextDay() }
            
            guard let completedWorkout = store.completedWorkout.list.first else { return }
            Router.shared.tab = .history
            Router.shared.push(CompletedWorkoutRoute(workout: completedWorkout))
            
            if store.completedWorkout.list.count >= 3 && !hasRated() {
                Router.shared.showRatingScreen = true
            }
        } catch {
            Router.shared.toast("Error saving workout", type: .error)
        }
    }
}


