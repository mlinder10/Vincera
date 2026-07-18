//
//  ExerciseView.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct ExerciseView: View {
    @ObservedObject var wrapper: Builder.Wrapper
    let previous: [Writers.Exercise]
    let hiddenIds: [String]
    var showsRpe = false
    var validate = false
    var disabled = false
    let removeWrapper: (Builder.Wrapper) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            if wrapper.exercises.count == 1 {
                InternalExerciseView(
                    exercise: wrapper.exercises[0],
                    previous: previous.first(where: { $0.listId == wrapper.exercises[0].listId }),
                    validate: validate,
                    disabled: disabled,
                    onAdd: handleAdd,
                    onReplace: handleReplace,
                    onDelete: handleDelete
                )
            } else {
                HStack(spacing: 16) {
                    Rectangle()
                        .fill(.backgroundSecondary)
                        .frame(width: 2)
                    VStack {
                        ForEach(wrapper.exercises) { exercise in
                            InternalExerciseView(
                                exercise: exercise,
                                previous: previous.first(where: { $0.listId == exercise.listId }),
                                validate: validate,
                                disabled: disabled,
                                onAdd: handleAdd,
                                onReplace: handleReplace,
                                onDelete: handleDelete
                            )
                            if exercise != wrapper.exercises.last {
                                Divider().padding(.vertical, 8)
                            }
                        }
                    }
                }
            }
            
            if !disabled && showsRpe {
                HStack {
                    DetailView(
                        icon: "gauge.open.with.lines.needle.33percent",
                        title: "Rate of Perceived Exertion (RPE)",
                        description: "RPE, or Rate of Perceived Exertion, is a scale used to measure the intensity of an exercise based on how difficult it feels. " +
                        "RPE ranges from 1 to 10, with higher numbers indicating greater effort.") {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                Text("RPE")
                            }
                        }
                    Spacer()
                    Picker("", selection: $wrapper.rpe) {
                        ForEach(1...10, id: \.self) { num in
                            Text("\(num)").tag(num)
                        }
                    }
                    .pickerStyle(.palette)
                }
            }
        }
    }
    
    private func handleAdd(_ exercise: Builder.Exercise) {
        Router.shared.push(
            ExerciseListRoute(
                hidden: hiddenIds,
                replacementId: nil,
                onTap: nil,
                onAdd: { exercises in
                    wrapper.addExercises(exercises, after: exercise)
                    Router.shared.pop()
                }
            )
        )
    }
    
    private func handleReplace(_ exercise: Builder.Exercise) {
        Router.shared.push(
            ExerciseListRoute(
                hidden: hiddenIds,
                replacementId: exercise.listId,
                onTap: { listItem in
                    wrapper.replace(exercise, with: listItem)
                    Router.shared.pop()
                },
                onAdd: nil
            )
        )
    }
    
    private func handleDelete(_ exercise: Builder.Exercise) {
        if wrapper.exercises.count == 1 {
            removeWrapper(wrapper)
        } else {
            wrapper.exercises.removeAll(where: { $0.id == exercise.id })
        }
    }
}

private struct InternalExerciseView: View {
    @ObservedObject var exercise: Builder.Exercise
    let previous: Writers.Exercise?
    let validate: Bool
    let disabled: Bool
    let onAdd: (Builder.Exercise) -> Void
    let onReplace: (Builder.Exercise) -> Void
    let onDelete: (Builder.Exercise) -> Void
    private let listItem: ListExercise
    
    init(
        exercise: Builder.Exercise,
        previous: Writers.Exercise?,
        validate: Bool,
        disabled: Bool,
        onAdd: @escaping (Builder.Exercise) -> Void,
        onReplace: @escaping (Builder.Exercise) -> Void,
        onDelete: @escaping (Builder.Exercise) -> Void
    ) {
        self.exercise = exercise
        self.previous = previous
        self.validate = validate
        self.disabled = disabled
        self.onAdd = onAdd
        self.onReplace = onReplace
        self.onDelete = onDelete
        self.listItem = ExerciseList.shared.getExercise(exercise.listId) ?? UNKNOWN_LIST_EXERCISE
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(listItem.name)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !disabled {
                    Menu("", systemImage: "ellipsis.circle") {
                        Button("Learn", systemImage: "book.fill") { Router.shared.push(ExercisePageRoute(exercise: listItem)) }
                        Button("Add", systemImage: "plus") { onAdd(exercise) }
                        Button("Replace", systemImage: "arrow.left.arrow.right") { onReplace(exercise) }
                        Button("Delete", systemImage: "trash", role: .destructive) { onDelete(exercise) }
                    }
                }
            }
            
            SetsView(
                exercise: exercise,
                previous: previous,
                listExercise: listItem,
                validate: validate,
                disabled: disabled
            )
            
            if !disabled {
                HStack {
                    BrandButton("Delete", role: .destructive, action: handleRemoveSet)
                        .secondary
                    BrandButton("Add", action: handleAddSet)
                        .secondary
                }
            }
        }
    }
    
    private func handleRemoveSet() {
        Keyboard.dismiss()
        guard exercise.sets.count > 1 else {
            Haptics.notify(.warning)
            return
        }
        
        withAnimation(.easeOut(duration: 0.2)) {
            exercise.removeSet()
        }
    }
    
    private func handleAddSet() {
        Keyboard.dismiss()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            exercise.addSet()
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack {
//            ExerciseView(
//                wrapper: .init(
//                    id: UUID().uuidString,
//                    rpe: 5,
//                    exercises: [
//                        .init(
//                            id: UUID().uuidString,
//                            listId: "0",
//                            sets: [
//                                .init(id: UUID().uuidString, type: .normal),
//                                .init(id: UUID().uuidString, type: .normal),
//                                .init(id: UUID().uuidString, type: .normal)
//                            ]
//                        )
//                    ]
//                ),
//                previous: [],
//                removeWrapper: { _ in }
//            )
            ExerciseView(
                wrapper: .init(
                    id: UUID().uuidString,
                    rpe: 5,
                    exercises: [
                        .init(
                            id: UUID().uuidString,
                            listId: "0",
                            sets: [
                                .init(id: UUID().uuidString, type: .normal),
                                .init(id: UUID().uuidString, type: .normal),
                                .init(id: UUID().uuidString, type: .normal)
                            ]
                        ),
                        .init(
                            id: UUID().uuidString,
                            listId: "1",
                            sets: [
                                .init(id: UUID().uuidString, type: .normal),
                                .init(id: UUID().uuidString, type: .normal),
                                .init(id: UUID().uuidString, type: .normal)
                            ]
                        )
                    ]
                ),
                previous: [],
                hiddenIds: ["0", "1"],
                showsRpe: true,
                removeWrapper: { _ in }
            )
        }
        .padding(.horizontal, PADDING_INLINE)
        .padding(.top, PADDING_TOP)
    }
}
