//
//  HistoryCharts.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/24/24.
//

import SwiftUI
import Charts

private let CHART_HEIGHT: CGFloat = 160

struct BodyPartGraph: View {
    let workouts: [Writers.CompletedWorkout]
    @State private var volume = [Volume]()
    @State private var median: Volume?
    
    var medianText: String {
        let str = "Median • "
        guard let median else { return str + "None" }
        return str + median.bodyPart.rawValue.capitalized + " (\(median.sets) sets)"
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("VOLUME / BODY PART")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Badge(medianText, color: median?.bodyPart.color ?? .accent)
                }
                
                VolumePieChart(volume: volume, size: CHART_HEIGHT)
            }
        }
        .task(id: workouts) {
            self.volume = workouts.flatMap({ $0.wrappers.getVolume() })
                .joined()
                .sorted { $0.sets > $1.sets }
            self.median = self.volume.sortedByAvg().median
        }
    }
}

struct TimeGraph: View {
    private let workouts: [Writers.CompletedWorkout]
    private var avg: Int
    
    init(workouts: [Writers.CompletedWorkout]) {
        self.workouts = workouts
        self.avg = workouts.isEmpty ? 0 : workouts.reduce(0) { $0 + $1.getMinutes() } / workouts.count
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TIME / WORKOUT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("Duration Trend")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    
                    Badge("Avg: \(avg) min", color: .accent)
                }
                
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.startedAt, unit: .day),
                            y: .value("Minutes", workout.getMinutes())
                        )
                        .foregroundStyle(.accent.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: CHART_HEIGHT)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                        AxisValueLabel(format: .dateTime.day())
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
            }
            .padding(4)
        }
    }
}

struct VolumeGraph: View {
    private let workouts: [Writers.CompletedWorkout]
    private var avg: Double
    
    init(workouts: [Writers.CompletedWorkout]) {
        self.workouts = workouts
        self.avg = workouts.isEmpty ? 0 : Double(
            workouts
                .flatMap({ $0.wrappers.flattened() })
                .reduce(0) { $0 + $1.sets.count}) / Double(workouts.count)
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("VOLUME / WORKOUT")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                        Text("Set Count Trend")
                            .font(.footnote)
                            .foregroundStyle(.tertiary)
                    }
                    Spacer()
                    
                    Badge("Avg: \(avg.formatted(.number.precision(.fractionLength(1)))) Sets", color: .accent)
                }
                
                Chart {
                    RuleMark(y: .value("Average", avg))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.accent.opacity(0.5))
                    
                    ForEach(workouts) { workout in
                        BarMark(
                            x: .value("Date", workout.startedAt, unit: .day),
                            y: .value("Sets", workout.wrappers.flattened().getVolume())
                        )
                        .foregroundStyle(.accent.gradient)
                        .cornerRadius(6)
                    }
                }
                .frame(height: CHART_HEIGHT)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 5)) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                        AxisValueLabel(format: .dateTime.day())
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.gray.opacity(0.2))
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
            }
            .padding(4)
        }
    }
}

struct LineSeparator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
