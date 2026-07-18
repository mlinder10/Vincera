//
//  Components.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

struct SetsView: View {
    @ObservedObject var exercise: Builder.Exercise
    let previous: Writers.Exercise?
    let listExercise: ListExercise
    let validate: Bool
    let disabled: Bool
    private let columns: [GridItem]
    
    init(
        exercise: Builder.Exercise,
        previous: Writers.Exercise?,
        listExercise: ListExercise,
        validate: Bool,
        disabled: Bool
    ) {
        self.exercise = exercise
        self.previous = previous
        self.listExercise = listExercise
        self.validate = validate
        self.disabled = disabled
        
        var items = [GridItem]()
        if listExercise.unitsOne != listExercise.unitsTwo {
            items = [GridItem(.fixed(32)), GridItem(), GridItem(), GridItem(), GridItem(.fixed(20))]
        } else {
            items = [GridItem(.fixed(32)), GridItem(), GridItem(), GridItem(.fixed(20))]
        }
        if disabled { items.removeLast() }
        self.columns = items
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
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    )
                )
            }
        }
    }
}

private struct SetRow: View {
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
            SetTypeView(type: $set.type, index: index + 1, disabled: disabled)
            
            previousButton
            
            NumberField("-", num: $set.valueOne, validate: validate)
                .disabled(disabled)
            
            if listExercise.unitsOne != listExercise.unitsTwo {
                NumberField("-", num: $set.valueTwo, validate: validate)
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
    
    @ViewBuilder
    private var previousButton: some View {
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

struct SetTypeView: View {
    @Binding var type: SetType
    let index: Int
    var disabled = false
    
    var body: some View {
        Group {
            if disabled { labelView }
            else { enabledView }
        }
    }
    
    @ViewBuilder
    private var labelView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(type.color)
                .frame(width: 32, height: 32)
            Text(type == .normal ? "\(index)" : type.letter)
        }
    }
    
    @ViewBuilder
    private var enabledView: some View {
        Menu {
            Picker(selection: $type, label: EmptyView()) {
                ForEach(SetType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type.rawValue)
                }
            }
            .pickerStyle(.inline)
        } label: {
            labelView
        }
        .foregroundStyle(.foreground)
    }
}

struct TabIndexView: View {
    let index: Int?
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { tab in
                Rectangle()
                    .fill(isCurrentTab(tab) ? .accent : .backgroundSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCurrentTab(tab) ? 4 : 2)
            }
        }
    }
    
    func isCurrentTab(_ tab: Int) -> Bool {
        if index == nil && tab == 0 { return true }
        return index == tab
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
                onAdd: {
                    wrapper.addExercises($0)
                    Router.shared.pop()
                }
            )
        )
    }
    
    private func handleReplace() {
        Router.shared.push(
            ExerciseListRoute(
                hidden: hidden,
                replacementId: wrapper.exercises.first?.listId,
                onTap: nil,
                onAdd: { _ in Router.shared.pop() }
            )
        )
    }
}
