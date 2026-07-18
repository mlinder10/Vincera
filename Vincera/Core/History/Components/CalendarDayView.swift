//
//  CalendarDayView.swift
//  Vincera
//
//  Created by Matt Linder on 5/27/26.
//

import SwiftUI

struct CalendarDayView: View {
    let components: CalendarComponents
    let workout: Writers.CompletedWorkout?
    
    var body: some View {
        Text(String(components.day))
            .font(.body)
            .fontWeight(components.isToday ? .bold : .regular)
            .foregroundStyle(components.isToday ? .blue : workout != nil ? .primary : .secondary)
            .frame(width: 32, height: 32)
            .background(
                Circle()
                    .fill(components.isToday ? Color.blue.opacity(0.15) : Color.clear)
            )
            .overlay(alignment: .bottom) {
                if workout != nil {
                    Circle()
                        .fill(.accent)
                        .frame(width: 5, height: 5)
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                if let workout = workout {
                    Router.shared.push(CompletedWorkoutRoute(workout: workout))
                }
            }
    }
}
