//
//  VolumeChart.swift
//  Vincera
//
//  Created by Matt Linder on 5/24/26.
//

import SwiftUI
import Charts

struct VolumePieChart: View {
    var title: String? = nil
    var subtitle: String? = nil
    let volume: [Volume]
    var size: CGFloat = 110
    var showsSetCount = false
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading) {
                    if let title {
                        Text(title)
                            .fontWeight(.semibold)
                            .font(.subheadline)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fontWeight(.semibold)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(volume) { vol in
                        if vol.sets > 0 {
                            HStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(vol.bodyPart.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(vol.bodyPart.rawValue.capitalized)
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                    .layoutPriority(1)
                                
                                Rectangle()
                                    .fill(.secondary.opacity(0.5))
                                    .frame(height: 1)
                                    .frame(maxWidth: .infinity)
                                    .frame(minWidth: 0)
                                
                                Text("\(volume.average(vol.bodyPart))%")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .layoutPriority(1)
                                
                                if showsSetCount {
                                    Group {
                                        Text("•")
                                        Text("\(vol.sets) sets")
                                    }
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                    .layoutPriority(1)
                                }
                            }
                            .padding(.trailing, 16)
                        }
                    }
                }
            }
            
            Chart {
                ForEach(volume) { vol in
                    SectorMark(
                        angle: .value(vol.bodyPart.rawValue, vol.sets),
                        innerRadius: .ratio(0.65),
                        angularInset: 1.5
                    )
                    .foregroundStyle(vol.bodyPart.color)
                    .cornerRadius(3)
                }
            }
            .frame(width: size, height: size)
            .chartLegend(.hidden)
        }
    }
}
