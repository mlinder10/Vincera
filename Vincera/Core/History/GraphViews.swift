//
//  GraphViews.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI
import Charts

private let CHART_HEIGHT: CGFloat = 160

struct TimeGraph: View {
    let workouts: [Writers.CompletedWorkout]
    var avg: Int {
        workouts.reduce(0) { $0 + $1.getMinutes() } / workouts.count
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading) {
                Label("Time / Workout", systemImage: "clock.fill")
                    .fontWeight(.semibold)
                Text("Average • \(String(avg)) min")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.secondary)
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.startedAt, unit: .weekdayOrdinal),
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
    let workouts: [Writers.CompletedWorkout]
    var avg: Double {
        Double(
            workouts
                .flatMap({ $0.wrappers.flattened() })
                .reduce(0) { $0 + $1.sets.count}) / Double(workouts.count
        )
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading) {
                Label("Volume / Workout", systemImage: "scalemass.fill")
                    .fontWeight(.semibold)
                Text("Average • \(avg.formatted(.number.precision(.fractionLength(2)))) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(.secondary)
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.startedAt, unit: .weekdayOrdinal),
                            y: .value("Sets", workout.wrappers.flattened().getVolume())
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
    @EnvironmentObject private var store: DataStore
    let components: CalendarComponents
    var volume: [Volume] { store.getVolume(during: components) }
    var median: Volume? { volume.sortedByAvg().median }
    
    var medianText: String {
        let str = "Median • "
        guard let median else { return str + "None" }
        return str + median.bodyPart.rawValue.capitalized + " (\(median.sets) sets)"
    }
    
    var body: some View {
        Card {
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
