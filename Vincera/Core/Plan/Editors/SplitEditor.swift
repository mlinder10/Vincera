//
//  SplitEditor.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

struct SplitEditor: View {
    @EnvironmentObject private var store: DataStore
    @ObservedObject private var split: Builder.Split
    
    init(_ split: Writers.Split?) {
        guard let split else { self.split = Builder.Split.new(); return }
        self.split = isSplitImmutable(splitId: split.id) ?
            split.clone().toBuilder() :
            split.toBuilder()
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                VStack {
                    TextField("Name", text: $split.name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Description", text: $split.description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                }
                
                SectionTitle("Days")
                
                DraggableForEach($split.days) { day in
                    DayRow(day: day) {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            handleRemoveDay(day.id)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { Router.shared.push(SplitDayEditorRoute(day: day)) }
                }
                
                BrandButton("Add Workout", action: split.addDay)
                    .secondary
                BrandButton("Save", action: handleSave)
                    .withAlert(title: "Save Split")
                    .primary
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Split")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                BrandButton("Discard", role: .destructive, action: Router.shared.pop)
                    .withAlert(title: "Discard")
            }
        }
    }
    
    private func handleRemoveDay(_ dayId: String) {
        split.days.removeAll(where: { $0.id == dayId })
    }
    
    private func handleSave() {
        do {
            if split.name.count == 0 { split.name = "Untitled Split" }
            if store.splits.contains(where: { $0.id == split.id }) {
                try store.editSplit(split.toWriter())
            } else {
                try store.createSplit(split.toWriter())
            }
            Router.shared.toast("Saved \(split.name)", type: .success)
            Router.shared.pop()
        } catch {
            Router.shared.toast("Error saving \(split.name)", type: .error)
        }
    }
}

fileprivate struct DayRow<Content: View>: View {
    @ObservedObject var day: Builder.Day
    @ViewBuilder var menuOptions: () -> Content
    
    var body: some View {
        Card {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.fromHex(day.color))
                    .frame(width: 8, height: 48)
                
                VStack(alignment: .leading) {
                    Text(day.name)
                        .fontWeight(.semibold)
                    HStack(spacing: 4) {
                        Text(day.wrappers.flattened().getBodyParts())
                        Text("•")
                        Text("\(day.wrappers.flattened().getVolume()) sets")
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button("", systemImage: day.isRest ? "moon.stars.fill" : "bolt.fill") {
                        day.isRest.toggle()
                    }
                    Menu("", systemImage: "ellipsis.circle", content: menuOptions)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct SplitDayEditor: View {
    @EnvironmentObject private var store: DataStore
    @ObservedObject var day: Builder.Day
    private var previous: [Writers.Exercise] {
        store.getPreviousExercises(
            listIds: day.wrappers
                .flattened()
                .map({ $0.listId })
        )
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                VStack {
                    TextField("Name", text: $day.name)
                        .textFieldStyle(.roundedBorder)
                    TextField("Description", text: $day.description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3, reservesSpace: true)
                    ColorPicker("Color", selection: Binding(get: { Color.fromHex(day.color) }, set: { day.color = $0.toHex() }))
                }
                
                Divider()
                
                DraggableForEach($day.wrappers, withDividers: true) { wrapper in
                    ExerciseView(
                        wrapper: wrapper,
                        previous: previous,
                        removeWrapper: { wrapper in
                            day.wrappers.removeAll(where: { $0.id == wrapper.id })
                        }) {
                            MenuOptions(
                                wrapper: wrapper,
                                hidden: day.wrappers.flattened().map({ $0.listId }),
                                removeExercise: { day.wrappers.removeAll(where: { $0.id == wrapper.id }) }
                            )
                        }
                }
                
                BrandButton("Add Exercise") {
                    Router.shared.push(
                        ExerciseListRoute(
                            hidden: day.wrappers.flattened().map({ $0.listId }),
                            replacementId: nil,
                            onTap: nil,
                            onAdd: { day.wrappers.addExercises($0); Router.shared.pop() }
                        )
                    )
                }
                .secondary
            }
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationTitle("Edit Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
}
