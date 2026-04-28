//
//  BuilderHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import Foundation
import SwiftUI

extension Builder.Split {
    func addDay() {
        days.append(
            Builder.Day(
                id: UUID().uuidString,
                name: "Day \(days.count + 1)",
                description: "",
                color: Color.random().toHex(),
                isRest: false,
                wrappers: []
            )
        )
    }
}

extension Array<Builder.Wrapper> {
    func flattened() -> [Builder.Exercise] {
        flatMap({ $0.exercises })
    }
    
    mutating func addExercises(_ exercises: [ListExercise]) {
        for e in exercises {
            append(
                Builder.Wrapper(
                    id: UUID().uuidString,
                    rpe: 5,
                    exercises: [Builder.Exercise.from(list: e)]
                )
            )
        }
    }
    
    func getAverageRPE() -> Double {
        if isEmpty { return 0 }
        return reduce(0) { $0 + Double($1.rpe) } / Double(count)
    }
}

extension Builder.Wrapper {
    func superset(_ exercises: [ListExercise]) {
        for e in exercises {
            self.exercises.append(Builder.Exercise.from(list: e))
        }
    }
    
    func replace(_ exercises: [ListExercise]) {
        self.exercises = []
        for e in exercises {
            self.exercises.append(Builder.Exercise.from(list: e))
        }
    }
}

extension Array<Builder.Exercise> {
    func getVolume() -> Int {
        reduce(0) { $0 + $1.sets.count }
    }
    
    func getBodyParts() -> String {
        Set(compactMap { exercise in
            ExerciseList.shared.getExercise(exercise.listId)?.bodyPart.capitalized
        })
        .sorted()
        .joined(separator: ", ")
    }
}

extension Builder.Exercise {
    func addSet() {
        sets.append(Builder.Set(id: UUID().uuidString, type: .normal))
    }
    
    func removeSet() {
        guard self.sets.count > 1 else { return }
        sets.removeLast()
    }
    
    func maxValue(for unit: ExerciseUnit) -> (Double, Double)? {
        let listExercise = ExerciseList.shared.getExercise(listId)
        if listExercise?.unitsOne == unit { return sets.maxValue(.one) }
        if listExercise?.unitsTwo == unit { return sets.maxValue(.two) }
        return nil
    }
    
    func canFillDown(_ index: Int) -> Bool {
        return (
            index + 1 < sets.count &&
            sets[index].valueOne != nil &&
            sets[index].valueTwo != nil &&
            sets[index+1].valueOne == nil &&
            sets[index+1].valueTwo == nil
        )
    }

    func fillDown(_ index: Int) {
        guard canFillDown(index) else { return }
        sets[index+1].valueOne = sets[index].valueOne
        sets[index+1].valueTwo = sets[index].valueTwo
    }
    
    func toString() -> String {
        let listEx = ExerciseList.shared.getExercise(self.listId)
        let reps = self.sets.first?.valueTwo ?? 0
        return (
            """
            Name - \(listEx?.name ?? "")
            Sets - \(self.sets.count)
            Reps - \(reps == 0 ? "Unspecified" : String(reps))
            """
        )
    }
}

extension Array<Builder.Set> {
    func maxValue(_ value: LLSetValueSelector) -> (Double, Double)? {
        let first = self
            .compactMap({ value == .one ? $0.valueOne : $0.valueTwo })
            .max()
        let second = value == .one ?
            self.first(where: { $0.valueOne == first })?.valueTwo :
            self.first(where: { $0.valueTwo == first})?.valueOne
        return (first ?? 0, second ?? 0)
    }
}

// completed / active

extension Builder.CompletedWorkout {
    func getMinutes() -> Int {
        Int(endedAt.timeIntervalSince(startedAt)) / 60
    }
}

extension Builder.ActiveWorkout {
    func isValid() -> Bool {
        for e in wrappers.flattened() {
            let listExercise = ExerciseList.shared.getExercise(e.listId)
            for set in e.sets {
                if listExercise?.unitsOne == listExercise?.unitsTwo {
                    if set.valueOne == nil { return false }
                } else {
                    if set.valueOne == nil || set.valueTwo == nil { return false }
                }
            }
        }
        return true
    }
    
    func progress() -> Double {
        let setCount = Double(wrappers.flattened().reduce(0) { $0 + $1.sets.count })
        if setCount == 0 { return 0.0 }
        let completed = Double(wrappers.flattened().reduce(0) { $0 + $1.sets.filter({ $0.valueOne != nil && $0.valueTwo != nil }).count })
        return completed / setCount
    }
}
