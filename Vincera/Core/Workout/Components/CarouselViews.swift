//
//  CarouselViews.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

private let INDICATOR_SIZE: CGFloat = 4

struct CarouselIndicators: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        HStack {
            ForEach(store.currentSplit?.days ?? []) { day in
                let isSelected = store.currentDay?.id == day.id
                let size = CGFloat(isSelected ? INDICATOR_SIZE * 1.5 : INDICATOR_SIZE)
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
    @EnvironmentObject private var store: DataStore
    let split: Writers.Split
    let day: Writers.Day
    let startWorkout: (Writers.Day?) -> Void
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                Text(split.name.uppercased())
                    .font(.caption2)
                    .fontWeight(.bold)
                    .tracking(1)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 12) {
                    DayIcon(name: day.name, color: day.color)
                    
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
                
                VStack {
                    WorkoutCellExercises(day: day)
                        .foregroundStyle(.primary.opacity(0.8))
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        BrandButton(
                            "Start",
                            systemImage:"bolt.fill",
                            action: { startWorkout(day) }
                        )
                        .primary
                        .disabled(day.isRest)
                        
                        BrandButton(
                            "Next",
                            systemImage: "forward.fill",
                            action: {
                                withAnimation {
                                    try? store.nextDay()
                                }
                            }
                        )
                        .secondary
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

let EXERCISE_COUNT = 5

private struct WorkoutCellExercises: View {
    private let day: Writers.Day
    private let exercises: [(Writers.Exercise, ListExercise)]
    
    init(day: Writers.Day) {
        self.day = day
        
        let exercises = day.wrappers.flattened()
        var result = [(Writers.Exercise, ListExercise)]()
        for e in exercises {
            if let listItem = ExerciseList.shared.getExercise(e.listId) {
                result.append((e, listItem))
            }
        }
        self.exercises = result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(exercises.prefix(EXERCISE_COUNT), id: \.0.id) { (exercise, listItem) in
                exerciseLineView(exercise: exercise, listItem: listItem)
            }
            
            if day.wrappers.count < EXERCISE_COUNT {
                ForEach(day.wrappers.count..<EXERCISE_COUNT, id: \.self) { _ in
                    Text("")
                }
            }
        }
        .if(day.wrappers.count > EXERCISE_COUNT) { content in
            content
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0.0),
                            .init(color: .black, location: 0.65),
                            .init(color: .black.opacity(0.1), location: 0.9),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
        }
    }
    
    @ViewBuilder
    private func exerciseLineView(exercise: Writers.Exercise, listItem: ListExercise) -> some View {
        HStack(spacing: 4) {
            Text("\(exercise.sets.count)x")
                .fontWeight(.semibold)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(.secondary)
            Text(listItem.name)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
        }
    }
}
