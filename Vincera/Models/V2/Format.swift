//
//  Format.swift
//  Vincera
//
//  Created by Matt Linder on 3/26/26.
//

import Foundation

extension Writers.Split {
    func formatted() -> String {
        var result = name
        
        for day in days {
            result += "\n\n\(day.name)"
            if day.isRest {
                result += " (Rest Day)"
                continue
            }
            
            for exercise in day.wrappers.flattened() {
                guard let details = ExerciseList.shared.getExercise(exercise.listId) else { continue }
                result += "\n - \(details.name) x\(exercise.sets.count)"
            }
        }
        
        return result
    }
    
    func formattedFull(_ store: DataStore) -> String {
        var result = name
        
        for day in days {
            result += "\n\n\(day.name)"
            if day.isRest {
                result += " (Rest Day)"
                continue
            }
            result += day.wrappers.formatted()
        }
        
        return result
    }
}

extension Writers.CompletedWorkout {
    func formatted() -> String {
        return name + wrappers.formatted()
    }
}

extension Array<Writers.Wrapper> {
    func formatted() -> String {
        var result = ""
        for exercise in self.flattened() {
            guard let details = ExerciseList.shared.getExercise(exercise.listId) else { continue }
            result += "\n - \(details.name)"
            for set in exercise.sets {
                result += "\n   • \(details.unitsOne): \(set.valueOne), \(details.unitsTwo): \(set.valueTwo)"
            }
        }
        return result
    }
}
