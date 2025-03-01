//
//  CodingKeys.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

extension Split {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _description = "description"
        case _days = "days"
    }
    
    static func == (lhs: Split, rhs: Split) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Day {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _description = "description"
        case _color = "color"
        case _exercises = "exercises"
    }
    
    static func == (lhs: Day, rhs: Day) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Workout {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _dayId = "dayId"
        case _name = "name"
        case _color = "color"
        case _start = "start"
        case _end = "end"
        case _exercises = "exercises"
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension SplitMeta {
    enum CodingKeys: String, CodingKey {
        case _splitId = "splitId"
        case _dayIndex = "dayIndex"
    }
    
    static func == (lhs: SplitMeta, rhs: SplitMeta) -> Bool {
        return (
            lhs.splitId == rhs.splitId &&
            lhs.dayIndex == rhs.dayIndex
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension WorkoutMeta {
    enum CodingKeys: String, CodingKey {
        case _prs = "prs"
        case _units = "units"
    }
    
    static func == (lhs: WorkoutMeta, rhs: WorkoutMeta) -> Bool {
        return lhs.prs == rhs.prs && lhs.units == rhs.units
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension Route {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .exercisePage(let exercise):
            hasher.combine(0)
            hasher.combine(exercise)
        case .exerciseList(let exercises, _, _):
            hasher.combine(1)
            hasher.combine(exercises)
        case .splitEditor(let split):
            hasher.combine(2)
            hasher.combine(split)
        case .splitDayEditor(let dayBinding):
            hasher.combine(3)
            hasher.combine(dayBinding.wrappedValue)
        case .dayEditor(let day):
            hasher.combine(4)
            hasher.combine(day)
        case .splitList:
            hasher.combine(5)
        case .createPr:
            hasher.combine(6)
        case .pastWorkout(let workoutBinding):
            hasher.combine(7)
            hasher.combine(workoutBinding.wrappedValue)
        case .createExercise:
            hasher.combine(8)
        case .settings:
            hasher.combine(9)
        }
    }
    
    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case let (.exercisePage(lhsExercise), .exercisePage(rhsExercise)):
            return lhsExercise == rhsExercise
            
        case let (.exerciseList(lhsExercises, _, _), .exerciseList(rhsExercises, _, _)):
            return lhsExercises == rhsExercises
            
        case let (.splitEditor(lhsSplit), .splitEditor(rhsSplit)):
            return lhsSplit == rhsSplit
            
        case let (.splitDayEditor(lhsDayBinding), .splitDayEditor(rhsDayBinding)):
            return lhsDayBinding.wrappedValue == rhsDayBinding.wrappedValue
            
        case let (.dayEditor(lhsDay), .dayEditor(rhsDay)):
            return lhsDay == rhsDay
            
        case (.splitList, .splitList),
            (.createPr, .createPr),
            (.createExercise, .createExercise),
            (.settings, .settings):
            return true
            
        case let (.pastWorkout(lhsWorkout), .pastWorkout(rhsWorkout)):
            return lhsWorkout.wrappedValue == rhsWorkout.wrappedValue
            
        default:
            return false
        }
    }
}
