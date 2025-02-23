//
//  CreatePRTrackerPage.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI

private let MAX_TRACKER_COUNT = 8

struct CreatePRTrackerPage: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var wStore: WorkoutStore
    @State private var toAdd = [(String, ExerciseUnit)]()
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(), GridItem()]) {
                    ForEach($wStore.meta.prs) {
                        TrackerCell(type: $0.type, listId: $0.wrappedValue.listId) { handleDelete($0, $1) }
                    }
                    ForEach($toAdd, id: \.wrappedValue.0) {
                        TrackerCell(type: $0.1, listId: $0.wrappedValue.0) { handleDelete($0, $1) }
                    }
                }
            }
            Button { handleSave() } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .borderedProminent
        }
        .padding()
        .navigationTitle("Track PR's")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    router.showDialog("Discard", role: .destructive, action: router.goBack)
                } label: {
                    Text("Discard")
                        .foregroundStyle(.red)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { handleAdd() } label: {
                    HStack {
                        Text("Add")
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }
    
    func handleAdd() {
        guard wStore.meta.prs.count + toAdd.count < MAX_TRACKER_COUNT else {
            router.notify(.warning, "Cannot track more than \(MAX_TRACKER_COUNT) PR's")
            return
        }
        router.goTo(
            .exerciseList(
                [],
                { toAdd.append(($0.id, .reps)); router.goBack() },
                { _ in }
            )
        )
    }
    
    func handleSave() {
        do {
            try wStore.batchCreatePrTrackers(toAdd)
            toAdd.removeAll()
            router.goBack()
        } catch {
            router.notify(.danger, "Error saving PR trackers")
        }
    }
    
    func handleDelete(_ listId: String, _ type: ExerciseUnit) {
        do {
            try wStore.deletePrTracker(listId, type)
            toAdd.removeAll(where: { $0.0 == listId && $0.1 == type })
        } catch {
            router.notify(.danger, "Error removing tracker")
        }
    }
}

fileprivate struct TrackerCell: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @EnvironmentObject private var eStore: ExerciseStore
    @Binding var type: ExerciseUnit
    let listId: String
    var exercise: ListExercise { eStore.getExercise(listId) ?? ListExercise.UNKNOWN }
    let handleDelete: (String, ExerciseUnit) -> Void
    
    var body: some View {
        VStack {
            HStack {
                Menu {
                    Picker(selection: $type, label: EmptyView()) {
                        ForEach(ExerciseUnit.allCases) {
                            Text($0.rawValue)
                                .tag($0)
                        }
                    }
                } label: {
                    type.label
                }
                Spacer()
                Menu {
                    Button(role: .destructive) { handleDelete(listId, type) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
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
        .padding()
        .backgroundRect(radius: 16, fill: .regularMaterial)
    }
}


#Preview {
    CreatePRTrackerPage()
}
