//
//  WorkoutRow.swift
//  Vincera
//
//  Created by Matt Linder on 8/1/25.
//

import SwiftUI

struct WorkoutRow: View {
    let workout: Writers.Workout
    
    var body: some View {
        Card {
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.fromHex(workout.color))
                    .frame(width: 8, height: 48)
                VStack(alignment: .leading) {
                    Text(workout.name)
                        .fontWeight(.semibold)
                    HStack(spacing: 4) {
                        Text(workout.wrappers.flattened().getBodyParts())
                        Text("•")
                        Text("\(workout.wrappers.flattened().getVolume()) sets")
                    }
                    .foregroundStyle(.secondary)
                    .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
