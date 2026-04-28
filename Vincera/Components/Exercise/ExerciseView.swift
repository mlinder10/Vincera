//
//  ExerciseView.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct ExerciseView<Content: View>: View {
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

fileprivate struct ExercisesScrollView: View {
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

fileprivate struct SetsView: View {
    @ObservedObject var exercise: Builder.Exercise
    let previous: Writers.Exercise?
    let listExercise: ListExercise
    let validate: Bool
    let disabled: Bool
    private var columns: [GridItem] {
        var items = [GridItem]()
        if listExercise.unitsOne != listExercise.unitsTwo {
            items = [GridItem(.fixed(32)), GridItem(), GridItem(), GridItem(), GridItem(.fixed(20))]
        } else {
            items = [GridItem(.fixed(32)), GridItem(), GridItem(), GridItem(.fixed(20))]
        }
        if disabled { items.removeLast() }
        return items
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            Text("Set")
            Text("Previous")
            Text(listExercise.unitsOne.rawValue)
            if listExercise.unitsOne != listExercise.unitsTwo {
                Text(listExercise.unitsTwo.rawValue)
            }
            if !disabled {
                Text("")
            }
            ForEach(exercise.sets.enumerated(), id: \.element.id) { (idx, set) in
                SetRow(
                    exercise: exercise,
                    set: set,
                    previous: previous,
                    listExercise: listExercise,
                    index: idx,
                    validate: validate,
                    disabled: disabled
                )
            }
        }
    }
}

fileprivate struct SetRow: View {
    @EnvironmentObject private var store: DataStore
    @ObservedObject var exercise: Builder.Exercise
    @ObservedObject var set: Builder.Set
    let previous: Writers.Exercise?
    let listExercise: ListExercise
    let index: Int
    let validate: Bool
    let disabled: Bool
    
    var body: some View {
        Group {
            SetTypeView(
                type: $set.type,
                index: index + 1,
                disabled: disabled
            )
            
            previousButton
            
            NumberField(
                "-",
                num: $set.valueOne,
                validate: validate
            )
            .disabled(disabled)
            
            if listExercise.unitsOne != listExercise.unitsTwo {
                NumberField(
                    "-",
                    num: $set.valueTwo,
                    validate: validate
                )
                .disabled(disabled)
            }
            
            if !disabled && index + 1 < exercise.sets.count {
                Button("", systemImage: "arrow.down") {
                    exercise.fillDown(index)
                }
                .disabled(!exercise.canFillDown(index))
            }
        }
    }
    
    private var previousButton: some View {
        Group {
            if !disabled, let vals = getPreviousValues(index) {
                let isSelected = hasSelectedPrevious(vals, index: index)
                Button("\(vals.0.formatted())x\(vals.1.formatted())") {
                    handleSelectPrevious(isSelected: isSelected, vals: vals)
                }
                .foregroundStyle(isSelected ? .secondary : .primary)
            } else {
                Text("-")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private func getPreviousValues(_ index: Int) -> (Double, Double)? {
        guard let previous else { return nil }
        guard previous.sets.count > index else { return nil }
        return (previous.sets[index].valueOne, previous.sets[index].valueTwo)
    }
    
    private func handleSelectPrevious(isSelected: Bool, vals: (Double, Double)) {
        if isSelected {
            Haptics.notify(.warning)
        } else {
            let newSet = exercise.sets[index]
            newSet.valueOne = vals.0
            newSet.valueTwo = vals.1
            exercise.sets[index] = newSet
        }
    }
    
    private func hasSelectedPrevious(_ vals: (Double, Double)?, index: Int) -> Bool {
        guard let vals, exercise.sets.count > index else { return false }
        return exercise.sets[index].valueOne == vals.0 && exercise.sets[index].valueTwo == vals.1
    }
}

struct MenuOptions: View {
    @ObservedObject var wrapper: Builder.Wrapper
    let hidden: [String]
    let removeExercise: () -> Void
    
    var body: some View {
        Group {
            Button("Superset", systemImage: "plus", action: handleSuperset)
            Button("Replace", systemImage: "arrow.left.arrow.right", action: handleReplace)
            Button("Delete", systemImage: "trash", role: .destructive, action: removeExercise)
        }
    }
    
    private func handleSuperset() {
        Router.shared.push(
            ExerciseListRoute(
                hidden: hidden,
                replacementId: nil,
                onTap: nil,
                onAdd: { wrapper.superset($0); Router.shared.pop() }
            )
        )
    }
    
    private func handleReplace() {
        Router.shared.push(
            ExerciseListRoute(
                hidden: hidden,
                replacementId: wrapper.exercises.first?.listId,
                onTap: nil,
                onAdd: { wrapper.replace($0); Router.shared.pop() }
            )
        )
    }
}
