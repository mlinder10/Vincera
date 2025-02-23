//
//  SplitEditor.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

private let DAY_CELL_HEIGHT: CGFloat = 120
private let DAY_CELL_RADIUS: CGFloat = 16

struct SplitEditor: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var sStore: SplitStore
    @EnvironmentObject private var eStore: ExerciseStore
    @State private var split: Split
    
    init(_ split: Split?) {
        if split?.isBuiltin() ?? false {
            self.split = split!.clone()
        } else {
            self.split = split?.cloneWithUUID() ?? Split()
        }
    }
    
    var body: some View {
        List {
            VStack {
                TextField("Name", text: $split.name)
                    .textFieldStyle(.roundedBorder)
                TextField("Description", text: $split.description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
            }
            .plainListStyle
            ForEach($split.days) { $day in
                Button {
                    router.goTo(.splitDayEditor($day))
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: DAY_CELL_RADIUS)
                            .fill(Color.fromHex(day.color))
                            .frame(height: DAY_CELL_HEIGHT)
                        RoundedRectangle(cornerRadius: DAY_CELL_RADIUS)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.background.opacity(0.8),
                                        Color.background.opacity(0),
                                        Color.background.opacity(0),
                                        Color.background.opacity(0)
                                    ],
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                            )
                            .frame(height: DAY_CELL_HEIGHT)
                        VStack {
                            Text(day.name)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(day.exercises.getBodyParts(eStore))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .frame(height: DAY_CELL_HEIGHT, alignment: .bottom)
                    }
                }
                .foregroundStyle(.primary)
                .plainListStyle
            }
            .onMove { split.moveDay(from: $0, to: $1) }
            .onDelete { split.deleteDay(at: $0) }
            Button { split.addDay() } label: {
                Text("Add Workout")
                    .frame(maxWidth: .infinity)
            }
            .bordered
            .plainListStyle
            Button { router.showDialog("Save Split", action: handleSave) } label: {
                Text("Save")
                    .frame(maxWidth: .infinity)
            }
            .borderedProminent
            .plainListStyle
        }
        .listRowSpacing(12)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Split")
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
        }
    }
    
    func handleSave() {
        do {
            if sStore.splits.contains(where: { $0.id == split.id }) {
                try sStore.editSplit(split)
            } else {
                try sStore.createSplit(split)
            }
            router.notify(.success, "Saved \(split.name)")
            router.goBack()
        } catch {
            router.notify(.danger, "Error saving \(split.name)")
        }
    }
}

struct SplitDayEditor: View {
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var dStore: DayStore
    @EnvironmentObject private var eStore: ExerciseStore
    @EnvironmentObject private var wStore: WorkoutStore
    @Binding var day: Day
    private var previous: [Exercise] { wStore.getPreviousExercises(listIds: day.exercises.flattened().map({ $0.listId })) }
    
    var body: some View {
        List {
            VStack {
                TextField("Name", text: $day.name)
                    .textFieldStyle(.roundedBorder)
                TextField("Description", text: $day.description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3, reservesSpace: true)
                ColorPicker("Color", selection: Binding(get: { Color.fromHex(day.color) }, set: { day.color = $0.toHex() }))
            }
            .plainListStyle
            ForEach($day.exercises, id: \.self) { $wrapper in
                ExerciseView(
                    exercises: $wrapper,
                    previous: previous,
                    removeWrapper: { day.exercises.remove($0) }) {
                        MenuOptions(
                            wrapper: $wrapper,
                            hidden: day.exercises.flattened().map({ $0.listId }),
                            removeExercise: { day.exercises.remove(wrapper) }
                        )
                    }
            }
            .onMove { day.exercises.move(from: $0, to: $1) }
            .plainListStyle
            buttons
                .plainListStyle
        }
        .listRowSpacing(12)
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var buttons: some View {
        VStack {
            Button {
                router.goTo(
                    .exerciseList(
                        day.exercises.flatMap({ $0.compactMap({ $0.listId }) }),
                        nil,
                        { day.exercises.addExercises($0); router.goBack() }
                    )
                )
            } label: {
                Text("Add Exercise")
                    .frame(maxWidth: .infinity)
            }
            .bordered
        }
    }
}
