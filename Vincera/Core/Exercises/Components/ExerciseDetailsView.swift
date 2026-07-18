//
//  ExerciseDetailsView.swift
//  Vincera
//
//  Created by Matt Linder on 5/29/26.
//

import SwiftUI

struct ExerciseDetailsView: View {
    let description: String?
    let directions: [String]?
    let cues: [String]?
    
    var body: some View {
        VStack {
            if description?.isEmpty == false ||
                directions?.isEmpty == false ||
                cues?.isEmpty == false {
                VStack(alignment: .leading, spacing: 12) {
                    if let description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle("Description")
                            Text(description)
                                .font(.subheadline)
//                                .foregroundStyle(.secondary)
                        }
                    }
                    if let directions, !directions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle("Directions")
                            ForEach(0..<directions.count, id: \.self) { index in
                                Text("\(index + 1). \(directions[index])")
                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    if let cues, !cues.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            SectionTitle("Cues")
                            ForEach(cues, id: \.self) { cue in
                                Text("• \(cue)")
                                    .font(.subheadline)
//                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}
