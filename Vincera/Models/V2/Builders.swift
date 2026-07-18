//
//  Builders.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI
import Foundation

enum Builder {
    final class Split: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        @Published var name: String
        @Published var description: String
        @Published var days: [Day]
        
        // protocol methods
        
        static func == (lhs: Builder.Split, rhs: Builder.Split) -> Bool {
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.days == rhs.days
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(description)
            hasher.combine(days)
        }
        
        // class methods
        
        init(id: String, name: String, description: String, days: [Day]) {
            self.id = id
            self.name = name
            self.description = description
            self.days = days
        }
        
        static func new() -> Split {
            Split(
                id: UUID().uuidString,
                name: "New Split",
                description: "",
                days: []
            )
        }
        
        func toWriter() -> Writers.Split {
            Writers.Split(
                id: id,
                name: name,
                description: description,
                days: days.map({ $0.toWriter() })
            )
        }
        
        func addRest(at index: Int? = nil) {
            let rest = Builder.Day(
                id: UUID().uuidString,
                name: "Rest",
                description: "",
                color: "#000000",
                isRest: true,
                wrappers: []
            )
            guard let index else {
                days.append(rest)
                return
            }
            days.insert(rest, at: index)
        }
    }
    
    final class Day: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        @Published var name: String
        @Published var description: String
        @Published var color: String
        @Published var isRest: Bool
        @Published var wrappers: [Wrapper]
        
        // protocol methods
        
        static func == (lhs: Builder.Day, rhs: Builder.Day) -> Bool {
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.description == rhs.description &&
            lhs.color == rhs.color &&
            lhs.isRest == rhs.isRest &&
            lhs.wrappers == rhs.wrappers
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(description)
            hasher.combine(color)
            hasher.combine(isRest)
            hasher.combine(wrappers)
        }
        
        // class methods
        
        init(id: String, name: String, description: String, color: String, isRest: Bool, wrappers: [Wrapper]) {
            self.id = id
            self.name = name
            self.description = description
            self.color = color
            self.isRest = isRest
            self.wrappers = wrappers
        }
        
        init(_ name: String, _ description: String) {
            self.id = UUID().uuidString
            self.name = name
            self.description = description
            self.color = Color.random().toHex()
            self.isRest = false
            self.wrappers = []
        }
        
        static func rest() -> Day {
            Day(
                id: UUID().uuidString,
                name: "Rest",
                description: "",
                color: Color.black.toHex(),
                isRest: true,
                wrappers: []
            )
        }
        
        func toWriter() -> Writers.Day {
            Writers.Day(
                id: id,
                name: name,
                description: description,
                color: color,
                isRest: isRest,
                wrappers: wrappers.map({ $0.toWriter() })
            )
        }
    }
    
    final class Wrapper: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        @Published var rpe: Int
        @Published var exercises: [Exercise]
        
        // protocol methods
        
        static func == (lhs: Builder.Wrapper, rhs: Builder.Wrapper) -> Bool {
            lhs.id == rhs.id &&
            lhs.rpe == rhs.rpe &&
            lhs.exercises == rhs.exercises
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(rpe)
            hasher.combine(exercises)
        }
        
        // class methods
        
        init(id: String, rpe: Int, exercises: [Exercise]) {
            self.id = id
            self.rpe = rpe
            self.exercises = exercises
        }
        
        static func fromList(_ exercise: ListExercise, setCount: Int = 3) -> Wrapper {
            Wrapper(
                id: UUID().uuidString,
                rpe: 5,
                exercises: [Exercise.from(list: exercise, setCount: setCount)]
            )
        }
        
        func toWriter() -> Writers.Wrapper {
            Writers.Wrapper(
                id: id,
                rpe: rpe,
                exercises: exercises.map({ $0.toWriter() })
            )
        }
    }
    
    final class Exercise: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        let listId: String
        @Published var sets: [Set]
        
        // protocol methods
        
        static func == (lhs: Builder.Exercise, rhs: Builder.Exercise) -> Bool {
            lhs.id == rhs.id &&
            lhs.listId == rhs.listId &&
            lhs.sets == rhs.sets
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(listId)
            hasher.combine(sets)
        }
        
        // class methods
        
        init(id: String, listId: String, sets: [Set]) {
            self.id = id
            self.listId = listId
            self.sets = sets
        }
        
        static func from(list: ListExercise, setCount: Int = 3) -> Exercise {
            let sets = list.exerciseType == "cardio" ?
                [Set(id: UUID().uuidString, type: .normal)] :
                Array.init(repeating: false, count: setCount)
                    .map({ _ in Set(id: UUID().uuidString, type: .normal) })
            
            return Exercise(
                id: UUID().uuidString,
                listId: list.id,
                sets: sets
            )
        }
        
        func toWriter() -> Writers.Exercise {
            Writers.Exercise(
                id: id,
                listId: listId,
                sets: sets.map({ $0.toWriter() })
            )
        }
    }
    
    final class Set: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        @Published var valueOne: Double?
        @Published var valueTwo: Double?
        @Published var type: SetType
        
        // protocol methods
        
        static func == (lhs: Builder.Set, rhs: Builder.Set) -> Bool {
            lhs.id == rhs.id &&
            lhs.valueOne == rhs.valueOne &&
            lhs.valueTwo == rhs.valueTwo &&
            lhs.type == rhs.type
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(valueOne)
            hasher.combine(valueTwo)
            hasher.combine(type)
        }
        
        // class methods
        
        init(id: String, valueOne: Double? = nil, valueTwo: Double? = nil, type: SetType) {
            self.id = id
            self.valueOne = valueOne
            self.valueTwo = valueTwo
            self.type = type
        }
        
        func toWriter() -> Writers.Set {
            Writers.Set(
                id: id,
                valueOne: valueOne ?? 0,
                valueTwo: valueTwo ?? 0,
                type: type
            )
        }
        
        func estimateMax() -> Double? {
            guard let valueOne, let valueTwo, valueTwo > 0 else { return nil }
            // Epley Formula: Weight * (1 + Reps / 30)
            return valueTwo == 1 ?
                valueOne :
                valueOne * (1.0 + (valueTwo / 30.0))
        }
    }
    
    // completed workout
    
    final class CompletedWorkout: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        let dayId: String?
        @Published var name: String
        @Published var notes: String
        @Published var color: Color
        @Published var startedAt: Date
        @Published var endedAt: Date
        @Published var wrappers: [Builder.Wrapper]
        
        // protocol methods
        
        static func == (lhs: Builder.CompletedWorkout, rhs: Builder.CompletedWorkout) -> Bool {
            lhs.id == rhs.id &&
            lhs.dayId == rhs.dayId &&
            lhs.name == rhs.name &&
            lhs.notes == rhs.notes &&
            lhs.color == rhs.color &&
            lhs.startedAt == rhs.startedAt &&
            lhs.endedAt == rhs.endedAt &&
            lhs.wrappers == rhs.wrappers
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(dayId)
            hasher.combine(name)
            hasher.combine(notes)
            hasher.combine(color)
            hasher.combine(startedAt)
            hasher.combine(endedAt)
            hasher.combine(wrappers)
        }
        
        // class methods
        
        init(id: String, dayId: String?, name: String, notes: String, color: Color, startedAt: Date, endedAt: Date, wrappers: [Builder.Wrapper]) {
            self.id = id
            self.dayId = dayId
            self.name = name
            self.notes = notes
            self.color = color
            self.startedAt = startedAt
            self.endedAt = endedAt
            self.wrappers = wrappers
        }
        
        func toWriter() -> Writers.CompletedWorkout {
            Writers.CompletedWorkout(
                id: id,
                dayId: dayId,
                name: name,
                notes: notes,
                color: color.toHex(),
                startedAt: startedAt,
                endedAt: endedAt,
                wrappers: wrappers.map({ $0.toWriter() })
            )
        }
    }
    
    // active workout
    
    final class ActiveWorkout: ObservableObject, Identifiable, Equatable, Hashable {
        let id: String
        let dayId: String?
        @Published var name: String
        @Published var notes: String
        @Published var color: Color
        @Published var startedAt: Date
        @Published var endedAt: Date?
        @Published var wrappers: [Builder.Wrapper]
        
        // protocol methods
        
        static func == (lhs: Builder.ActiveWorkout, rhs: Builder.ActiveWorkout) -> Bool {
            lhs.id == rhs.id &&
            lhs.dayId == rhs.dayId &&
            lhs.name == rhs.name &&
            lhs.notes == rhs.notes &&
            lhs.color == rhs.color &&
            lhs.startedAt == rhs.startedAt &&
            lhs.endedAt == rhs.endedAt &&
            lhs.wrappers == rhs.wrappers
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(dayId)
            hasher.combine(name)
            hasher.combine(notes)
            hasher.combine(color)
            hasher.combine(startedAt)
            hasher.combine(endedAt)
            hasher.combine(wrappers)
        }
        
        // class methods
        
        init(id: String, dayId: String?, name: String, notes: String, color: Color, startedAt: Date, endedAt: Date? = nil, wrappers: [Builder.Wrapper]) {
            self.id = id
            self.dayId = dayId
            self.name = name
            self.notes = notes
            self.color = color
            self.startedAt = startedAt
            self.endedAt = endedAt
            self.wrappers = wrappers
        }
        
        static func new() -> ActiveWorkout {
            ActiveWorkout(
                id: UUID().uuidString,
                dayId: nil,
                name: "New Workout",
                notes: "",
                color: Color.random(),
                startedAt: Date(),
                endedAt: nil,
                wrappers: []
            )
        }
        
        func toCompleted() -> Writers.CompletedWorkout {
            Writers.CompletedWorkout(
                id: id,
                dayId: dayId,
                name: name,
                notes: notes,
                color: color.toHex(),
                startedAt: startedAt,
                endedAt: endedAt ?? Date(),
                wrappers: wrappers.map({ $0.toWriter() })
            )
        }
        
        func toWriter() -> Writers.ActiveWorkout {
            Writers.ActiveWorkout(
                id: id,
                dayId: dayId,
                name: name,
                notes: notes,
                color: color.toHex(),
                startedAt: startedAt,
                endedAt: endedAt,
                wrappers: wrappers.map({ $0.toWriter() })
            )
        }
    }
}
