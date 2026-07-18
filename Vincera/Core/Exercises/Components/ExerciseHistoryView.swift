//
//  ExerciseHistoryView.swift
//  Vincera
//
//  Created by Matt Linder on 5/29/26.
//

import SwiftUI
import Charts

// TODO: replace computed properties with state
struct ExerciseHistoryView: View {
    @EnvironmentObject private var store: DataStore
    @State private var timeframe: Timeframe = .threeMonths
    let exercise: ListExercise
    
    private var previous: [(Writers.Exercise, Date)] {
        store.getAllPreviousExercises(for: exercise.id, since: timeframe)
    }
    
    // Helper flag to verify if a composite strength volume chart is mathematically possible
    private var isWeightAndReps: Bool {
        exercise.unitsOne == .weight && exercise.unitsTwo == .reps
    }
    
    // 1. Calculate Estimated 1-Rep Max for the premier tracker card
    private var estimatedMaxData: [ExerciseHistoryDataPoint] {
        guard isWeightAndReps else { return [] }
        
        return previous.compactMap { (workoutExercise, date) in
            let setMaxes = workoutExercise.sets.compactMap({ $0.estimateMax() })
            guard let peakEstimatedMax = setMaxes.max() else { return nil }
            return .init(date: date, value: peakEstimatedMax)
        }
        .sorted(by: { $0.date < $1.date })
    }
    
    private var chartDataOne: [ExerciseHistoryDataPoint] {
        previous.compactMap { (workoutExercise, date) in
            guard let maxVal = workoutExercise.sets.map({ $0.valueOne }).max() else { return nil }
            return .init(date: date, value: maxVal)
        }
        .sorted(by: { $0.date < $1.date })
    }
    
    private var chartDataTwo: [ExerciseHistoryDataPoint] {
        previous.compactMap { (workoutExercise, date) in
            guard let maxVal = workoutExercise.sets.map({ $0.valueTwo }).max() else { return nil }
            return .init(date: date, value: maxVal)
        }
        .sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    SectionTitle("Progress")
                    Spacer()
                    
                    Picker("Timeframe", selection: $timeframe.animation(.easeInOut(duration: 0.2))) {
                        ForEach(Timeframe.allCases) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 180)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if previous.isEmpty {
                    ContentUnavailableView(
                        "No Data for this Period",
                        systemImage: "calendar.badge.exclamationmark",
                        description: Text("Try selecting a wider timeframe to review your logs.")
                    )
                    .frame(height: 200)
                } else {
                    VStack(spacing: 20) {
                        // Dynamically append the Estimated Strength Profile card if metrics line up
                        if isWeightAndReps {
                            Card {
                                ExerciseHistoryChart(
                                    title: "Estimated 1RM (Strength)",
                                    data: estimatedMaxData,
                                    timeframe: timeframe,
                                    color: .purple
                                )
                            }
                        }
                        
                        if exercise.unitsOne == exercise.unitsTwo {
                            Card {
                                ExerciseHistoryChart(
                                    title: exercise.unitsOne.rawValue,
                                    data: chartDataOne,
                                    timeframe: timeframe,
                                    color: .blue
                                )
                            }
                        } else {
                            Card {
                                ExerciseHistoryChart(
                                    title: exercise.unitsOne.rawValue,
                                    data: chartDataOne,
                                    timeframe: timeframe,
                                    color: .blue
                                )
                            }
                            Card {
                                ExerciseHistoryChart(
                                    title: exercise.unitsTwo.rawValue,
                                    data: chartDataTwo,
                                    timeframe: timeframe,
                                    color: .orange
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
        }
    }
}
