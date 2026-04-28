//
//  CarouselViews.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

struct CarouselIndicators: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        HStack {
            ForEach(store.currentSplit?.days ?? []) { day in
                let isSelected = store.currentDay?.id == day.id
                let size = CGFloat(isSelected ? 8 : 6)
                let opacity = CGFloat(isSelected ? 1 : 0.7)
                Circle()
                    .frame(width: size, height: size)
                    .foregroundStyle(Color.gray.opacity(opacity))
                    .animation(.spring(duration: 0.2), value: isSelected)
            }
        }
    }
}

struct WorkoutCarouselItem: View {
    let split: Writers.Split
    let day: Writers.Day
    let startWorkout: (Writers.Day?) -> Void
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                // Header: Split Name + Action Icon
                Text(split.name.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1)
                    .foregroundStyle(.secondary)
                
                // Day Info
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fromHex(day.color).opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Text(day.name.prefix(1))
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.fromHex(day.color))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.name)
                            .font(.headline)
                        Text(day.wrappers.flattened().getBodyParts())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Divider().opacity(0.5)
                
                // Exercise List
                WorkoutCellExercises(day: day)
                    .foregroundStyle(.primary.opacity(0.8))
                
                Spacer(minLength: 0)
            }
            .padding(4) // Extra breathing room inside the Card
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 200)
        }
        .contentShape(Rectangle())
        .onTapGesture { startWorkout(day) }
    }
}

fileprivate struct WorkoutCellExercises: View {
    let day: Writers.Day
    
    var body: some View {
        VStack(alignment: .leading) {
            if day.wrappers.count <= 5 {
                fittingView
            } else {
                overflowView
            }
        }
    }
    
    private var fittingView: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(day.wrappers.prefix(5)) { wrapper in
                if let exercise = wrapper.exercises.first,
                   let listItem = ExerciseList.shared.getExercise(exercise.listId) {
                    HStack(spacing: 4) {
                        Text("\(exercise.sets.count)x")
                            .fontWeight(.semibold)
                            .font(.system(.subheadline, design: .monospaced)) // Monospaced keeps numbers aligned
                            .foregroundStyle(.secondary)
                        Text(listItem.name)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                }
            }
        }
    }
    
    private var overflowView: some View {
        VStack(alignment: .leading) {
            ForEach(0..<4, id: \.self) { index in
                if let exercise = day.wrappers[index].exercises.first,
                   let listItem = ExerciseList.shared.getExercise(exercise.listId) {
                    Text("\(String(exercise.sets.count))x \(listItem.name)")
                }
            }
            Text("...")
                .font(.subheadline)
        }
    }
}
