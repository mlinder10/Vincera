//
//  HistoricalGraphViews.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI
import Charts

private let CHART_HEIGHT: CGFloat = 160

struct TimeGraph: View {
    let workouts: [Workout]
    var avg: Double { workouts.reduce(0) { $0 + Double($1.getMinutes()) } / Double(workouts.count) }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("Time / Workout", systemImage: "clock.fill")
                    .fontWeight(.semibold)
                Text("Average • \(avg.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.secondary)
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.start, unit: .weekdayOrdinal),
                            y: .value("Minutes", workout.getMinutes())
                        )
                        .foregroundStyle(.accent)
                    }
                }
                .frame(height: CHART_HEIGHT)
            }
        }
    }
}

struct VolumeGraph: View {
    let workouts: [Workout]
    var avg: Double { Double(workouts.flatMap({ $0.exercises.flattened() }).reduce(0) { $0 + $1.sets.count}) / Double(workouts.count) }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("Volume / Workout", systemImage: "scalemass.fill")
                    .fontWeight(.semibold)
                Text("Average • \(avg.formatted())")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.secondary)
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.start, unit: .weekdayOrdinal),
                            y: .value("Sets", workout.exercises.getVolume())
                        )
                        .foregroundStyle(.accent)
                    }
                }
                .frame(height: CHART_HEIGHT)
            }
        }
    }
}

struct BodyPartGraph: View {
    @EnvironmentObject private var wStore: WorkoutStore
    @EnvironmentObject private var eStore: ExerciseStore
    let timeframe: Timeframe
    var volume: [Volume] { wStore.getVolume(eStore, timeframe: timeframe) }
    var median: Volume? { volume.sortedByAvg().median }
    
    var medianText: String {
        let str = "Median • "
        guard let median else { return str + "None" }
        return str + median.bodyPart.rawValue.capitalized + " (\(median.sets) sets)"
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading) {
                Label("Volume / Body Part", systemImage: "scalemass.fill")
                    .fontWeight(.semibold)
                Text(medianText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VolumePieChart(volume: volume, size: CHART_HEIGHT)
            }
        }
    }
}
