//
//  ExerciseViewOld.swift
//  Vincera
//
//  Created by Matt Linder on 5/28/26.
//

import SwiftUI

private struct ExerciseViewOld<Content: View>: View {
    @State private var scrollItemId: Builder.Exercise.ID? = nil
    private var scrollIndex: Int? { wrapper.exercises.firstIndex(where: { $0.id == scrollItemId }) }
    private var currentExercise: Builder.Exercise? { scrollIndex == nil ? wrapper.exercises.first : wrapper.exercises[scrollIndex!] }
    private var listExercise: ListExercise { ExerciseList.shared.getExercise(currentExercise?.listId ?? "") ?? UNKNOWN_LIST_EXERCISE }
    
    @ObservedObject var wrapper: Builder.Wrapper
    let previous: [Writers.Exercise]
    var showsRpe: Bool = false
    var validate: Bool = false
    var disabled = false
    let removeWrapper: (Builder.Wrapper) -> Void
    let menuItems: () -> Content
    
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(listExercise.name)
                    .fontWeight(.semibold)
                Spacer()
                if !disabled {
                    Menu("", systemImage: "ellipsis.circle") {
                        Button("Learn", systemImage: "book", action: handleOpenExercisePage)
                        menuItems()
                    }
                }
            }
            
            ExercisesScrollView(
                wrapper: wrapper,
                scrollItemId: $scrollItemId,
                listExercise: listExercise,
                scrollIndex: scrollIndex,
                previous: previous,
                validate: validate,
                disabled: disabled
            )
            
            if !disabled {
                HStack {
                    Text("Delete Set")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .backgroundRect(radius: 6, fill: .regularMaterial)
                        .onTapGesture { handleRemoveSet() }
                    Text("Add Set")
                        .font(.subheadline)
                        .foregroundStyle(.accent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .backgroundRect(radius: 6, fill: .regularMaterial)
                        .onTapGesture { handleAddSet() }
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
    
    func handleOpenExercisePage() {
        guard let currentExercise, let exercise = ExerciseList.shared.getExercise(currentExercise.listId) else { return }
        Router.shared.push(ExercisePageRoute(exercise: exercise))
    }
    
    func handleRemoveSet() {
        guard let currentExercise else { return }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        guard currentExercise.sets.count > 1 else {
            Haptics.notify(.warning)
            return
        }
    
        wrapper.exercises[scrollIndex ?? 0].removeSet()
    }
    
    func handleAddSet() {
        guard wrapper.exercises.count > 0 else { return }
        wrapper.exercises[scrollIndex ?? 0].addSet()
    }
}

private struct ExercisesScrollView: View {
    @ObservedObject var wrapper: Builder.Wrapper
    @Binding var scrollItemId: Builder.Exercise.ID?
    let listExercise: ListExercise
    let scrollIndex: Int?
    let previous: [Writers.Exercise]
    let validate: Bool
    let disabled: Bool
    
    var body: some View {
        Group {
            if wrapper.exercises.count > 1 {
                TabIndexView(
                    index: scrollIndex,
                    total: wrapper.exercises.count
                )
            }
            ScrollView(.horizontal) {
                HStack {
                    ForEach(wrapper.exercises) { ex in
                        let p = previous.first(where: { $0.listId == ex.listId })
                        SetsView(
                            exercise: ex,
                            previous: p,
                            listExercise: listExercise,
                            validate: validate,
                            disabled: disabled
                        )
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollItemId)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
        }
    }
}
