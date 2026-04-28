//
//  Writers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import Foundation
import SwiftUI

enum Writers {
    struct SplitMeta: Codable {
        var splitId: String?
        var dayIndex: Int?
    }
    
    struct Split: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let name: String
        let description: String
        let days: [Day]
        
        func toBuilder() -> Builder.Split {
            Builder.Split(
                id: id,
                name: name,
                description: description,
                days: days.map({ $0.toBuilder() })
            )
        }
        
        func clone() -> Split {
            Split(
                id: UUID().uuidString,
                name: name,
                description: description,
                days: days
            )
        }
    }
    
    struct Day: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let name: String
        let description: String
        let color: String
        let isRest: Bool
        let wrappers: [Wrapper]
        
        func toBuilder() -> Builder.Day {
            Builder.Day(
                id: id,
                name: name,
                description: description,
                color: color,
                isRest: isRest,
                wrappers: wrappers.map({ $0.toBuilder() })
            )
        }
        
        func toActive() -> Builder.ActiveWorkout {
            let active = Builder.ActiveWorkout(
                id: UUID().uuidString,
                dayId: id,
                name: name,
                notes: "",
                color: Color.fromHex(color),
                startedAt: Date(),
                endedAt: nil,
                wrappers: wrappers.map({ $0.toBuilder() })
            )
            for s in active.wrappers.flattened().flatMap({ $0.sets }) {
                s.valueOne = nil
                s.valueTwo = nil
            }
            return active
        }
    }
    
    struct Workout: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let name: String
        let description: String
        let color: String
        let wrappers: [Wrapper]
        
        func toBuilder() -> Builder.Workout {
            Builder.Workout(
                id: id,
                name: name,
                description: description,
                color: Color.fromHex(color),
                wrappers: wrappers.map({ $0.toBuilder() })
            )
        }
        
        func clone() -> Workout {
            Workout(
                id: UUID().uuidString,
                name: name,
                description: description,
                color: color,
                wrappers: wrappers
            )
        }
        
        func toActive() -> Builder.ActiveWorkout {
            let active = Builder.ActiveWorkout(
                id: UUID().uuidString,
                dayId: id,
                name: name,
                notes: "",
                color: Color.fromHex(color),
                startedAt: Date(),
                endedAt: nil,
                wrappers: wrappers.map({ $0.toBuilder() })
            )
            for s in active.wrappers.flattened().flatMap({ $0.sets }) {
                s.valueOne = nil
                s.valueTwo = nil
            }
            return active
        }
    }
    
    struct Wrapper: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let rpe: Int
        let exercises: [Exercise]
        
        init(id: String, rpe: Int, exercises: [Exercise]) {
            self.id = id
            self.rpe = rpe
            self.exercises = exercises
        }
        
        init(_ exercises: [Exercise]) {
            self.id = UUID().uuidString
            self.rpe = 5
            self.exercises = exercises
        }
        
        func toBuilder() -> Builder.Wrapper {
            Builder.Wrapper(
                id: id,
                rpe: rpe,
                exercises: exercises.map({ $0.toBuilder() })
            )
        }
    }
    
    struct Exercise: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let listId: String
        let sets: [Set]
        
        init(id: String, listId: String, sets: [Set]) {
            self.id = id
            self.listId = listId
            self.sets = sets
        }
        
        init(listId: String, sets: [Int]) {
            self.id = UUID().uuidString
            self.listId = listId
            self.sets = sets.map({
                Set(
                    id: UUID().uuidString,
                    valueOne: 0,
                    valueTwo: Double($0),
                    type: .normal
                )
            })
        }
        
        func toBuilder() -> Builder.Exercise {
            Builder.Exercise(
                id: id,
                listId: listId,
                sets: sets.map({ $0.toBuilder() })
            )
        }
    }
    
    struct Set: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let valueOne: Double
        let valueTwo: Double
        let type: SetType
        
        func toBuilder() -> Builder.Set {
            Builder.Set(
                id: id,
                valueOne: valueOne,
                valueTwo: valueTwo,
                type: type
            )
        }
    }
    
    // completed workout

    struct PRTracker: Codable, Hashable, Identifiable {
        var id: String { listId + type.rawValue }
        let listId: String
        var type: ExerciseUnit
    }

    struct PRTrackerValues: Codable, Hashable, Identifiable {
        var id: String { listId + type.rawValue }
        let listId: String
        var type: ExerciseUnit
        let valOne: Double?
        let valTwo: Double?
    }
    
    struct CompletedWorkout: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let dayId: String?
        let name: String
        let notes: String
        let color: String
        let startedAt: Date
        let endedAt: Date
        let wrappers: [Wrapper]
        
        func toBuilder() -> Builder.CompletedWorkout {
            Builder.CompletedWorkout(
                id: id,
                dayId: dayId,
                name: name,
                notes: notes,
                color: Color.fromHex(color),
                startedAt: startedAt,
                endedAt: endedAt,
                wrappers: wrappers.map({ $0.toBuilder() })
            )
        }
    }
    
    struct ActiveWorkout: Codable, Identifiable, Equatable, Hashable {
        let id: String
        let dayId: String?
        let name: String
        let notes: String
        let color: String
        let startedAt: Date
        let endedAt: Date?
        let wrappers: [Writers.Wrapper]
        
        func toBuilder() -> Builder.ActiveWorkout {
            let workout = Builder.ActiveWorkout(
                id: id,
                dayId: dayId,
                name: name,
                notes: notes,
                color: Color.fromHex(color),
                startedAt: startedAt,
                endedAt: endedAt,
                wrappers: wrappers.map({ $0.toBuilder() })
            )
            for s in workout.wrappers.flattened().flatMap({ $0.sets }) {
                if s.valueOne == 0 && s.valueTwo == 0 {
                    s.valueOne = nil
                    s.valueTwo = nil
                }
            }
            return workout
        }
    }
}
