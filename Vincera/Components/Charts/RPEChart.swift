//
//  RPEChart.swift
//  Vincera
//
//  Created by Matt Linder on 5/31/26.
//

import SwiftUI
import Charts

// Unified semantic color mapping for RPE tiers
func rpeToColor<T: BinaryFloatingPoint>(_ rpe: T) -> Color {
    if rpe < 6.0 { return .green }       // < 6: Warm-up / Speed / Technique
    if rpe < 8.0 { return .yellow }      // 6.0 - 7.5: Moderate Hypertrophy / RIR 3-2
    if rpe < 9.5 { return .orange }      // 8.0 - 9.0: Heavy Effective Reps / RIR 2-1
    return .red                          // 9.5 - 10: Peak Intensity / Failure
}

// Overload helper for integer lookups
func rpeToColor(_ rpe: Int) -> Color {
    rpeToColor(Double(rpe))
}

private struct RPEDataPoint: Identifiable {
    var id: Int { index }
    let value: Int
    let index: Int
}

struct RPEChart: View {
    private let title: String
    private let data: [RPEDataPoint]
    private let average: Double
    private let lineGradient: LinearGradient
    
    init(title: String, rpeData: [Int]) {
        let nonZeroData = rpeData.filter { $0 > 0 }
        guard !nonZeroData.isEmpty else {
            self.title = title
            self.data = []
            self.average = 0.0
            self.lineGradient = LinearGradient(colors: [.orange], startPoint: .bottom, endPoint: .top)
            return
        }
        
        self.title = title
        self.data = nonZeroData.enumerated().map { index, value in
            RPEDataPoint(value: value, index: index + 1)
        }
        self.average = Double(nonZeroData.reduce(0, +)) / Double(nonZeroData.count)
        
        let minRPE = nonZeroData.min()!
        let maxRPE = nonZeroData.max()!
        
        self.lineGradient = LinearGradient(
            stops: [
                .init(color: rpeToColor(minRPE), location: 0.0),
                .init(color: rpeToColor(maxRPE), location: 1.0)
            ],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerView
            
            if data.isEmpty {
                ContentUnavailableView("No RPE Logged", systemImage: "chart.linear.trend.upline")
                    .frame(height: 160)
            } else {
                Chart {
                    chartLine
                    chartArea
                    chartPoints
                    
                    RuleMark(y: .value("Average", average))
                        .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
                        .foregroundStyle(rpeToColor(average).opacity(0.4))
                }
                .frame(height: 160)
                .chartYScale(domain: 1...11) // Give a tiny buffer at the top so annotations aren't clipped
                .chartXScale(domain: 0.6...Double(max(2, data.count)) + 0.4) // Extra margin for end nodes
                
                .chartXAxis {
                    AxisMarks(values: data.map { $0.index }) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.quaternary)
                        if let index = value.as(Int.self) {
                            AxisValueLabel(anchor: .top) {
                                Text("Ex \(index)")
                                    .font(.system(.caption2, design: .rounded))
                                    .fontWeight(.medium)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: [2, 4, 6, 8, 10]) { value in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(.quaternary)
                        AxisValueLabel()
                            .font(.system(.caption2, design: .rounded))
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).dataTitle
                
                Text("Intensity Trend")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            let avgFormatted = average.formatted(.number.precision(.fractionLength(0...1)))
            Badge("• Avg: @RPE \(avgFormatted)", color: rpeToColor(average))
        }
    }
    
    @ChartContentBuilder
    private var chartLine: some ChartContent {
        ForEach(data) { point in
            LineMark(
                x: .value("Exercise", point.index),
                y: .value("RPE", point.value)
            )
        }
        .interpolationMethod(.catmullRom)
        .foregroundStyle(lineGradient)
        .lineStyle(StrokeStyle(lineWidth: 3.5, lineCap: .round, lineJoin: .round))
    }
    
    @ChartContentBuilder
    private var chartPoints: some ChartContent {
        ForEach(data) { point in
            PointMark(
                x: .value("Exercise", point.index),
                y: .value("RPE", point.value)
            )
            .annotation(position: .top, alignment: .center, spacing: 4) {
                Text("\(point.value)")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
            }
            .symbol {
                Circle()
                    .fill(rpeToColor(point.value))
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 2)
                    )
            }
        }
    }
    
    @ChartContentBuilder
    private var chartArea: some ChartContent {
        ForEach(data) { point in
            AreaMark(
                x: .value("Exercise", point.index),
                y: .value("RPE", point.value)
            )
            .foregroundStyle(
                LinearGradient(
                    stops: [
                        .init(color: rpeToColor(average).opacity(0.0), location: 0.0),
                        .init(color: rpeToColor(average).opacity(0.2), location: 1.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .interpolationMethod(.catmullRom)
    }
}

// Inline extension mapping fallback for the inner grid aesthetic if needed
private extension ShapeStyle where Self == Color {
    static var trendLineGridColor: Color {
        Color(.separator).opacity(0.3)
    }
}
