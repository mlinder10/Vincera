//
//  CompletedWorkoutsListView.swift
//  Vincera
//
//  Created by Matt Linder on 5/27/26.
//

import SwiftUI

struct CompletedWorkoutsListView: View {
    let workouts: [Writers.CompletedWorkout]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionTitle("Completed Workouts")
            
            LazyVStack {
                ForEach(workouts) { workout in
                    CompletedWorkoutRowView(workout: workout)
                    
                    if workout.id != workouts.last?.id {
                        Divider()
                            .padding(.leading, 24)
                    }
                }
            }
        }
    }
}

private struct CompletedWorkoutRowView: View {
    @EnvironmentObject private var store: DataStore
    let workout: Writers.CompletedWorkout
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.fromHex(workout.color))
                .frame(width: 4)
                .padding(.vertical, 8)
            
            VStack(alignment: .leading) {
                Text(workout.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(workout.wrappers.flattened().getBodyParts())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer(minLength: 12)
            
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(workout.getMinutes())")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                    Text("min")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                .frame(width: 45, alignment: .trailing)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(workout.wrappers.flattened().getVolume())")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.bold)
                    Text("sets")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                .frame(width: 40, alignment: .trailing)
            }
            
            Menu("", systemImage: "ellipsis.circle") {
                contextMenu
            }
        }
        .padding(.vertical, 4)
        .contentShape(.rect)
        .contextMenu { contextMenu }
        .onTapGesture {
            Router.shared.push(CompletedWorkoutRoute(workout: workout))
        }
    }
    
    @ViewBuilder
    private var contextMenu: some View {
            Button("Edit", systemImage: "pencil") {
                Router.shared.push(CompletedWorkoutRoute(workout: workout))
            }
            Button(
                "Delete",
                systemImage: "trash",
                role: .destructive,
                action: handleDelete
            )
    }
    
    private func handleDelete() {
        do {
            try store.completedWorkout.delete(workout)
        } catch {
            Router.shared.toast("Error deleting \(workout.name)", type: .error)
        }
    }
}
