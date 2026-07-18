//
//  HistoryScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct HistoryScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var date = Date()
    @State private var workouts = [Writers.CompletedWorkout]()
    @State private var calendarMap = [CalendarComponents: Writers.CompletedWorkout?]()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                RecordListView()
                
                VStack(spacing: 16) {
                    SectionTitle("Workout Data")
                    CalendarView(date: $date) {
                        CalendarDayView(
                            components: $0,
                            workout: calendarMap[$0] ?? nil
                        )
                    }
                }
                
                if !workouts.isEmpty {
                    VStack(spacing: 16) {
                        VolumeGraph(workouts: workouts)
                        TimeGraph(workouts: workouts)
                        BodyPartGraph(workouts: workouts)
                    }
                }
                
                if !workouts.isEmpty {
                    CompletedWorkoutsListView(workouts: workouts)
                }
            }
            .padding(.vertical, PADDING_TOP)
            .padding(.horizontal, PADDING_INLINE)
        }
        .scrollIndicators(.hidden)
        .navigationTitle("History")
        
        .task(id: date) {
            let newComponents = date.getComponents()
            let filteredWorkouts = store.getFiltered(during: newComponents)
            let newMap = computeMap(during: newComponents, using: filteredWorkouts)
            self.workouts = filteredWorkouts
            self.calendarMap = newMap
        }
    }
}

private func computeMap(
    during components: CalendarComponents,
    using workouts: [Writers.CompletedWorkout]
) -> [CalendarComponents: Writers.CompletedWorkout?] {
    var result = [CalendarComponents: Writers.CompletedWorkout?]()
    
    let month = History.Month.allCases[components.month - 1]
    for day in 1...(History.MONTH_DAY_COUNT[month] ?? 1) {
        let key = CalendarComponents(day: day, month: components.month, year: components.year)
        
        for workout in workouts {
            if workout.startedAt.getComponents() == key {
                result[key] = workout
                break
            }
            
            // don't currently need to check because workouts are already filtered for the month
//            else if workout.startedAt.getComponents() < key {
//                // workouts start with most recent
//                // if workout.startedAt < key (workout is older than date), we've gone past it
//                break
//            }
        }
    }
    
    return result
}

#Preview {
    HistoryScreen()
        .mockNavigation
        .mockEnvironment
}
