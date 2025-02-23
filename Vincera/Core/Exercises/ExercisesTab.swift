//
//  ExercisesTab.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct ExercisesTab: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var eStore: ExerciseStore
    @State private var selected = [ListExercise]()
    @State private var filter: ExerciseStore.Filter
    private var exercises: [String: [ListExercise]] { eStore.getFiltered(filter).groupByPrimaryGroup() }
    private var onTap: ((ListExercise) -> Void)?
    private var onAdd: (([ListExercise]) -> Void)?
    
    init(_ hidden: [String] = [], onTap: ((ListExercise) -> Void)? = nil, onAdd: (([ListExercise]) -> Void)? = nil) {
        filter = ExerciseStore.Filter(hidden: hidden)
        self.onTap = onTap
        self.onAdd = onAdd
    }
    
    var body: some View {
        List {
            filters
            ForEach(exercises.sorted(by: { $0.key < $1.key}), id: \.key) {
                GroupCell(group: $0, selected: $selected, onTap: onTap, onAdd: onAdd)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Exercises")
        .searchable(text: $filter.search)
        .toolbar {
            if let onAdd, !selected.isEmpty {
                ToolbarItem(placement: .bottomBar) {
                    Button { onAdd(selected) } label: {
                        Text("Add \(selected.count) Exercise\(selected.count == 1 ? "" : "s")")
                            .frame(maxWidth: .infinity)
                    }
                    .borderedProminent
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { router.goTo(.createExercise) } label: {
                    Label("Create", systemImage: "plus")
                }
            }
        }
    }
    
    var filters: some View {
        Section("Filter") {
            VStack(spacing: 8) {
                FilterRow(selected: $filter.bodyParts, title: "Body Part", options: BodyPart.allCases)
                FilterRow(selected: $filter.exerciseTypes, title: "Exercise Type", options: ExerciseType.allCases)
                FilterRow(selected: $filter.equipmentTypes, title: "Equipment Type", options: EquipmentType.allCases)
            }
            .plainListStyle
        }
    }
}

fileprivate struct GroupCell: View {
    @EnvironmentObject private var router: Router
    let group: Dictionary<String, [ListExercise]>.Element
    @Binding var selected: [ListExercise]
    let onTap: ((ListExercise) -> Void)?
    let onAdd: (([ListExercise]) -> Void)?
    
    var body: some View {
        Section(group.key) {
            ForEach(group.value) { ex in
                ExerciseCell(exercise: ex, isSelected: selected.contains(where: { $0.id == ex.id })) {
                    if onAdd != nil {
                        if let onTap { onTap($0) } else { selected.toggle($0) }
                    } else {
                        router.goTo(.exercisePage($0))
                    }
                }
            }
        }
    }
}

fileprivate struct ExerciseCell: View {
    @EnvironmentObject private var router: Router
    let exercise: ListExercise
    let isSelected: Bool
    let onTap: (ListExercise) -> Void
    
    var body: some View {
        Button { onTap(exercise) } label: {
            HStack {
                Text(exercise.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
                Button { router.goTo(.exercisePage(exercise)) } label: {
                    Image(systemName: "info.circle")
                }
                .foregroundStyle(.accent)
            }
        }
        .foregroundStyle(.primary)
    }
}

#Preview {
    ExercisesTab()
}
