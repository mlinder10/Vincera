//
//  ExerciseHistoryChart.swift
//  Vincera
//
//  Created by Matt Linder on 5/31/26.
//

import SwiftUI
import Charts

struct ExerciseHistoryDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct ExerciseHistoryChart: View {
    let title: String
    let data: [ExerciseHistoryDataPoint]
    let timeframe: Timeframe
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).dataTitle
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value(title, point.value)
                    )
                    .interpolationMethod(.linear)
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value(title, point.value)
                    )
                    .foregroundStyle(color)
                }
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: calculateStrideCount(for: data))) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.quaternary)
                    
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            if timeframe == .oneMonth || timeframe == .threeMonths {
                                Text(date, format: .dateTime.month(.abbreviated).day())
                                    .font(.caption2)
                            } else {
                                Text(date, format: .dateTime.month(.abbreviated).year(.twoDigits))
                                    .font(.caption2)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5)).foregroundStyle(.quaternary)
                    AxisValueLabel()
                }
            }
        }
    }
    
    private func calculateStrideCount(for data: [ExerciseHistoryDataPoint]) -> Int {
        guard let first = data.first?.date, let last = data.last?.date else { return 1 }
        let calendar = Calendar.current
        let daysCount = calendar.dateComponents([.day], from: first, to: last).day ?? 0
        
        if daysCount <= 31 { return 7 }
        if daysCount <= 93 { return 14 }
        if daysCount <= 186 { return 30 }
        return 60
    }
}
