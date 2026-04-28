//
//  CreatePRTrackerPage.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI

private let MAX_TRACKER_COUNT = 8

struct CreatePRTrackerScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var toAdd = [(String, ExerciseUnit)]()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach($store.trackers) {
                        TrackerCell(type: $0.type, listId: $0.wrappedValue.listId) { handleDelete($0, $1) }
                    }
                    ForEach($toAdd, id: \.wrappedValue.0) {
                        TrackerCell(type: $0.1, listId: $0.wrappedValue.0) { handleDelete($0, $1) }
                    }
                }
            }
            BrandButton("Save", action: handleSave)
                .primary
        }
        .padding()
        .navigationTitle("Track PR's")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandButton("Discard", role: .destructive, action: Router.shared.pop)
                    .withAlert(title: "Discard")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add", systemImage: "plus.circle", action: handleAdd)
            }
        }
    }
    
    private func handleAdd() {
        guard store.trackers.count + toAdd.count < MAX_TRACKER_COUNT else {
            Router.shared.toast("Cannot track more than \(MAX_TRACKER_COUNT) PR's", type: .warning)
            return
        }
        Router.shared.push(
            ExerciseListRoute(
                hidden: [],
                replacementId: nil,
                onTap: { toAdd.append(($0.id, .reps)); Router.shared.pop() },
                onAdd: { _ in }
            )
        )
    }
    
    private func handleSave() {
        do {
            try store.createPRTrackers(toAdd)
            toAdd.removeAll()
            Router.shared.pop()
        } catch {
            Router.shared.toast("Error saving PR trackers", type: .error)
        }
    }
    
    private func handleDelete(_ listId: String, _ type: ExerciseUnit) {
        do {
            try store.deletePRTracker(listId, type)
            toAdd.removeAll(where: { $0.0 == listId && $0.1 == type })
        } catch {
            Router.shared.toast("Error removing tracker", type: .error)
        }
    }
}

fileprivate struct TrackerCell: View {
    @Binding var type: ExerciseUnit
    let listId: String
    var exercise: ListExercise { ExerciseList.shared.getExercise(listId) ?? ListExercise.UNKNOWN }
    let handleDelete: (String, ExerciseUnit) -> Void
    
    var body: some View {
        Card {
            VStack {
                HStack {
                    Menu(type.rawValue, systemImage: type.icon) {
                        Picker(selection: $type, label: EmptyView()) {
                            ForEach(ExerciseUnit.allCases) {
                                Text($0.rawValue)
                                    .tag($0)
                            }
                        }
                    }
                    Spacer()
                    Menu("", systemImage: "ellipsis.circle") {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            handleDelete(listId, type)
                        }
                    }
                }
                Text(exercise.name)
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.vertical)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


#Preview {
    CreatePRTrackerScreen()
}
