//
//  CompletedWorkoutScreen.swift
//  Vincera
//
//  Created by Matt Linder on 10/27/24.
//

import SwiftUI

// Ideas for this page:
//
// 1. highlight exercises where users beat last week's values
// ✅ 2. add a "top set" card calculated with e1RM (will have to do some filtering / sorting of exercise priority ex. compounds should be displayed over isolations)
// ✅ 3. change color of avg RPE based on value and show graph of RPE through workout
// ✅ 4. include average pace (minutes / set)

private struct TopSetData {
    let exercise: ListExercise
    let estimate: Double
    let weight: Double
    let reps: Int
}

struct CompletedWorkoutScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var isEditing = false // Should not be replaced with \.editMode
    @State private var cachedPrevious: [Writers.Exercise] = [] // used instead of computed property
    @State private var topSet: TopSetData?
    @ObservedObject var workout: Builder.CompletedWorkout
    
    init(workout: Writers.CompletedWorkout) {
        self.workout = workout.toBuilder()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                headerView
                
                if isEditing { editDateView }
                else { dateView }
    
                Divider().padding(.vertical, 4)
                
                if !isEditing {
                    metadataView
                    Divider().padding(.vertical, 4)
                }
                
                exercisesView
                
                if isEditing {
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
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Done" : "Edit", action: handleEditToggle)
            }
        }
        .onAppear {
            updatePreviousCache()
            updateTopSet()
        }
        .onChange(of: workout.wrappers) { _, _ in
            updatePreviousCache()
            updateTopSet()
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        Group {
            if isEditing {
                TextField("Workout Name", text: $workout.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            } else {
                Text(workout.name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.top, 4)
        
        if isEditing {
            TextField("Notes", text: $workout.notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .lineLimit(3, reservesSpace: true)
        } else if !workout.notes.isEmpty {
            Text(workout.notes)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("No workout notes recorded.")
                .font(.subheadline)
                .italic()
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    @ViewBuilder
    private var dateView: some View {
        HStack(spacing: 8) {
            let startString = workout.startedAt.formatted(
                date: .abbreviated,
                time: .shortened)
            let endString = workout.endedAt.formatted(
                date: .omitted,
                time: .shortened)
            
            Label("\(startString) to \(endString)", systemImage: "play.circle.fill")
            
            Spacer()
            
            Label(workout.getMinutes().secondFormatted, systemImage: "clock.fill")
                .fontWeight(.medium)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(8)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
    
    @ViewBuilder
    private var editDateView: some View {
        VStack(spacing: 8) {
            DatePicker(
                "Start Time",
                selection: $workout.startedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            DatePicker(
                "End Time",
                selection: $workout.endedAt,
                displayedComponents: [.date, .hourAndMinute] // also shows date in case workout was started just before midnight
            )
        }
        .font(.subheadline)
    }
    
    @ViewBuilder
    private var metadataView: some View {
        VStack(spacing: 16) {
            Card {
                RPEChart(
                    title: "RPE Through Workout",
                    rpeData: workout.wrappers.map({ $0.rpe })
                )
            }
            
            HStack(spacing: 16) {
                Card {
                    VStack(alignment: .leading, spacing: 6) {
                        if let topSet {
                            let formattedWeight = topSet.weight.formatted(.number.precision(.fractionLength(0)))
                            
                            Text("Top Set").dataTitle
                            Badge(topSet.exercise.name)
                            HStack {
                                Text("\(formattedWeight)x\(topSet.reps)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                Card {
                    let totalSets = workout.wrappers.flattened().getVolume()
                    let workoutDuration = workout.getMinutes()
                    let minsPerSet = Double(workoutDuration) / Double(totalSets)
                    let mpsFormatted = minsPerSet.formatted(.number.precision(.fractionLength(0...1)))
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total Volume").dataTitle
                        Badge("\(mpsFormatted) mins / set")
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(totalSets.formatted())
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Sets")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }
                }
            }
            
            Card {
                VolumePieChart(
                    title: "Volume Breakdown",
                    volume: workout.wrappers.getVolume(),
                    showsSetCount: true
                )
            }
        }
    }
    
    @ViewBuilder
    private var exercisesView: some View {
        DraggableForEach(
            $workout.wrappers,
            withDividers: true,
            disabled: !isEditing
        ) { wrapper in
            ExerciseView(
                wrapper: wrapper,
                previous: cachedPrevious,
                hiddenIds: workout.wrappers.flattened().map({ $0.listId }),
                showsRpe: true,
                disabled: !isEditing,
                removeWrapper: handleRemoveWrapper
            )
            .contentShape(Rectangle())
        }
    }
    
    // updator functions
    
    private func updatePreviousCache() {
        cachedPrevious = store.getPreviousExercises(
            listIds: workout.wrappers.flattened().map({ $0.listId }),
            workoutId: workout.id
        )
    }
    
    private func updateTopSet() {
        var topSet: TopSetData?
        
        for e in workout.wrappers.flattened() {
            guard let listItem = ExerciseList.shared.getExercise(e.listId),
                  listItem.unitsOne == .weight, listItem.unitsTwo == .reps else { continue }
            for s in e.sets {
                guard let estimate = s.estimateMax() else { continue }
                
                let isHeavier = estimate > (topSet?.estimate ?? 0)
                let isCurrentCompound = listItem.exerciseType == "compound"
                let isExistingCompound = topSet?.exercise.exerciseType == "compound"
                
                if !isExistingCompound && isHeavier ||
                    !isExistingCompound && isCurrentCompound ||
                    isCurrentCompound && isHeavier {
                    topSet = .init(
                        exercise: listItem,
                        estimate: estimate,
                        // can be force unwrapped since estimateMax would return nil if empty
                        weight: s.valueOne!,
                        reps: Int(s.valueTwo!)
                    )
                }
            }
        }
        
        self.topSet = topSet
    }
    
    // UI interactions
    
    private func handleRemoveWrapper(_ wrapper: Builder.Wrapper) {
        workout.wrappers.removeAll(where: { $0.id == wrapper.id })
    }
    
    private func handleEditToggle() {
        if !isEditing {
            isEditing = true
            return
        }
        do {
            if workout.name.isEmpty { workout.name = "Empty" }
            try store.completedWorkout.edit(workout.toWriter())
            isEditing = false
        } catch {
            Router.shared.toast("Error saving changes", type: .error)
        }
    }
}
