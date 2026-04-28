//
//  ExerciseListScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct ExerciseListScreen: View {
    @State private var selected = [ListExercise]()
    @State private var filter: ExerciseList.Filter
    private let replacementId: String?
    private var exercises: [String: [ListExercise]] {
        ExerciseList.shared
            .getFiltered(filter)
            .groupByPrimaryGroup()
    }
    private var recommended: [ListExercise]? {
        guard let replacementId, replacementId.count != UUID().uuidString.count else { return nil }
        return try? DatabaseManager.shared.fetchSimilar(
            exerciseId: replacementId,
            filter: filter
        )
    }
    private var onTap: ((ListExercise) -> Void)?
    private var onAdd: (([ListExercise]) -> Void)?
    
    init(
        _ hidden: [String] = [],
        replacementId: String? = nil,
        onTap: ((ListExercise) -> Void)? = nil,
        onAdd: (([ListExercise]) -> Void)? = nil
    ) {
        self.replacementId = replacementId
        self.onTap = onTap
        self.onAdd = onAdd
        filter = ExerciseList.Filter(hidden: hidden)
    }
    
    var body: some View {
        List {
            filters
            if let recommended {
                GroupCell(
                    title: "Recommended",
                    exercises: recommended,
                    selected: $selected,
                    onTap: onTap,
                    onAdd: onAdd
                )
            }
            ForEach(exercises.sorted(by: { $0.key < $1.key}), id: \.key) {
                GroupCell(
                    title: $0.key,
                    exercises: $0.value,
                    selected: $selected,
                    onTap: onTap,
                    onAdd: onAdd
                )
            }
            Color.clear
                .frame(height: PADDING_TOP)
                .plainListStyle
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay(alignment: .bottom) {
            Group {
                if let onAdd, !selected.isEmpty {
                    Text("Add \(selected.count) Exercise\(selected.count == 1 ? "" : "s")")
                        .frame(maxWidth: .infinity)
                        .borderedProminent
                        .onTapGesture { onAdd(selected) }
                        .padding(.horizontal)
                        .padding(.bottom)
                        .transition(.move(edge: .bottom))
                        .animation(.bouncy, value: selected.isEmpty)
                }
            }
        }
        .searchable(text: $filter.search)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create", systemImage: "plus") {
                    Router.shared.push(CreateExerciseRoute())
                }
            }
        }
    }
    
    private var filters: some View {
        Section(header:
            VStack(spacing: 8) {
                MultiSelectRow("Body Part", selected: $filter.bodyParts, options: BodyPart.allCases)
                MultiSelectRow("Exercise Type", selected: $filter.exerciseTypes, options: ExerciseType.allCases)
                MultiSelectRow("Equipment Type", selected: $filter.equipmentTypes, options: EquipmentType.allCases)
            }
        ) {}
    }
}

fileprivate struct GroupCell: View {
    let title: String
    let exercises: [ListExercise]
    @Binding var selected: [ListExercise]
    let onTap: ((ListExercise) -> Void)?
    let onAdd: (([ListExercise]) -> Void)?
    
    var body: some View {
        Section(title.capitalized) {
            ForEach(exercises) { ex in
                ExerciseCell(exercise: ex, isSelected: selected.contains(where: { $0.id == ex.id })) {
                    if onAdd != nil {
                        if let onTap { onTap($0) } else { selected.toggle($0) }
                    } else {
                        Router.shared.push(ExercisePageRoute(exercise: $0))
                    }
                }
            }
        }
    }
}

fileprivate struct ExerciseCell: View {
    let exercise: ListExercise
    let isSelected: Bool
    let onTap: (ListExercise) -> Void
    
    var body: some View {
        HStack {
            HStack {
                Text(exercise.name)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accent)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { withAnimation { onTap(exercise) } }
            
            Button("", systemImage: "info.circle") {
                Router.shared.push(ExercisePageRoute(exercise: exercise))
            }
            .foregroundStyle(.accent)
        }
        
    }
}

#Preview {
    ExerciseListScreen()
        .mockNavigation
        .mockEnvironment
}
