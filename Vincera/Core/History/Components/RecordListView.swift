//
//  RecordListView.swift
//  Vincera
//
//  Created by Matt Linder on 5/27/26.
//

import SwiftUI

struct RecordListView: View {
    @EnvironmentObject private var store: DataStore
    @State private var records = [Writers.PRTrackerValues]()
    
    var body: some View {
        VStack {
            SectionTitle("Personal Records") {
                Button("Add", systemImage: "plus") {
                    Router.shared.push(
                        ExerciseListRoute(
                            hidden: records.map({ $0.listId }),
                            replacementId: nil,
                            onTap: nil,
                            onAdd: handleAdd
                        )
                    )
                }
            }
            if store.tracker.list.isEmpty {
                EmptyCard(
                    title: "No Personal Records Tracked",
                    description: "Edit your personal records list to keep an eye on your best lifts"
                )
            } else {
                Card {
                    LazyVStack {
                        ForEach(records) { record in
                            PRCellView(tracker: record)
                            if record.id != records.last?.id {
                                Divider().padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { records = store.getPrs() }
    }
    
    private func handleAdd(_ exercises: [ListExercise]) {
        do {
            try store.tracker.createMany(
                exercises.map({
                    Writers.PRTracker(
                        listId: $0.id,
                        type: $0.unitsOne
                    )
                })
            )
            Router.shared.pop()
        } catch {
            Router.shared.toast("Failed to add personal record", type: .error)
        }
    }
}

private struct PRCellView: View {
    @EnvironmentObject private var store: DataStore
    private let tracker: Writers.PRTrackerValues
    private let exercise: ListExercise
    
    init(tracker: Writers.PRTrackerValues) {
        self.tracker = tracker
        self.exercise = ExerciseList.shared.getExercise(tracker.listId) ?? UNKNOWN_LIST_EXERCISE
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tracker.type.icon)
                .font(.title3)
                .foregroundStyle(.accent)
                .frame(width: 32, height: 32)
                .background(Color.accent.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(tracker.type == .weight ? "Max Weight" : "Max Reps")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer(minLength: 16)
            
            // MARK: - PR Data Badge
            Card(.capsule, vPadding: 4, hPadding: 8) {
                if let one = tracker.valOne {
                    HStack(spacing: 4) {
                        if tracker.type == .reps {
                            // e.g., "12 reps @ 135 lbs" if you track both, or just custom handling:
                            Text("\(one.formatted())")
                                .font(.body)
                                .fontWeight(.bold)
                            Text("reps")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else if tracker.type == .weight {
                            Text("\(one.formatted())")
                                .font(.body)
                                .fontWeight(.bold)
                            
                            if let two = tracker.valTwo {
                                Text("x\(two.formatted())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("lbs") // Or your localized unit string
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            // Fallback fallback
                            Text("\(one.formatted())")
                                .font(.body)
                                .fontWeight(.bold)
                        }
                    }
                } else {
                    Text("No Record")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Menu("", systemImage: "ellipsis.circle") {
                contextMenu
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .contextMenu { contextMenu }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
        if exercise.unitsOne != exercise.unitsTwo {
            Button(action: handleToggleType) {
                Label("Change Type", systemImage: "arrow.left.arrow.right")
            }
        }
        Button(role: .destructive, action: handleDelete) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    private func handleToggleType() {
        let newType = tracker.type == exercise.unitsOne ? exercise.unitsTwo : exercise.unitsOne
        do {
            try store.tracker.edit(.init(listId: tracker.listId, type: newType))
        } catch {
            Router.shared.toast("Failed to edit record", type: .error)
        }
    }
    
    private func handleDelete() {
        do {
            try store.tracker.delete(.init(listId: tracker.listId, type: tracker.type))
        } catch {
            Router.shared.toast("Failed to delete record", type: .error)
        }
    }
}
