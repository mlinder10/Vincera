//
//  WriterHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

extension Writers.Split {
    func getVolume() -> [Volume] {
        var parts = BodyPart.allCases.map { Volume(bodyPart: $0, sets: 0) }
        
        let exercises = self.days.flatMap { $0.wrappers.flattened() }
        let listExercises = exercises.map { ExerciseList.shared.getExercise($0.listId) }
        
        for e in zip(exercises, listExercises) {
            guard let listExercise = e.1 else { continue }
            guard let part = BodyPart(rawValue: listExercise.bodyPart) else { continue }
            guard let index = parts.firstIndex(where: { $0.bodyPart == part }) else { continue }
            parts[index].sets += e.0.sets.count
        }
        
        return parts
    }
}

extension Array<Writers.Wrapper> {
    func flattened() -> [Writers.Exercise] {
        flatMap({ $0.exercises })
    }
    
    func getAverageRPE() -> Double {
        self.reduce(0) { $0 + Double($1.rpe) } / Double(self.count)
    }
}

extension Array<Writers.Exercise> {
    func getBodyParts() -> String {
        Set(compactMap { exercise in
            ExerciseList.shared.getExercise(exercise.listId)?.bodyPart.capitalized
        })
        .sorted()
        .joined(separator: ", ")
    }
    
    func getVolume() -> Int {
        self.reduce(0) { $0 + $1.sets.count }
    }
}

extension Writers.Exercise {
    func maxValue(for unit: ExerciseUnit) -> (Double, Double)? {
        let listExercise = ExerciseList.shared.getExercise(listId)
        if listExercise?.unitsOne == unit { return sets.maxValue(.one) }
        if listExercise?.unitsTwo == unit { return sets.maxValue(.two) }
        return nil
    }
}

extension Array<Writers.Set> {
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

extension Array<Writers.CompletedWorkout> {
    func sortedByDate() -> [Writers.CompletedWorkout] {
        sorted { $0.startedAt > $1.startedAt }
    }
}

extension Writers.CompletedWorkout {
    func getMinutes() -> Int {
        Int(endedAt.timeIntervalSince(startedAt)) / 60
    }
}
