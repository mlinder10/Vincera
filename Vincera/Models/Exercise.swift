//
//  Exercise.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

private let ADD_SET_COUNT = 3

struct Exercise: Codable, Identifiable, Hashable {
    var id: String
    var listId: String
    var rpe: Int
    var unitOne: ExerciseUnit
    var unitTwo: ExerciseUnit
    var sets: [VinceraSet]

    init(
        id: String,
        listId: String,
        rpe: Int,
        unitOne: ExerciseUnit,
        unitTwo: ExerciseUnit,
        sets: [VinceraSet]
    ) {
        self.id = id
        self.listId = listId
        self.rpe = rpe
        self.unitOne = unitOne
        self.unitTwo = unitTwo
        self.sets = sets
    }

    init(_ listExercise: ListExercise) {
        self.id = UUID().uuidString
        self.listId = listExercise.id
        self.rpe = 5
        self.unitOne = listExercise.equipmentType == "bodyweight" ? ExerciseUnit.weightPlus : ExerciseUnit.weight
        self.unitTwo = ExerciseUnit.reps
        self.sets = [VinceraSet(), VinceraSet(), VinceraSet()]
    }

    init(_ exercise: Exercise) {
        self.id = UUID().uuidString
        self.listId = exercise.listId
        self.rpe = 5
        self.unitOne = exercise.unitOne
        self.unitTwo = exercise.unitTwo
        self.sets = exercise.sets.map { _ in VinceraSet() }
    }

    init(
        listId: String,
        unitOne: ExerciseUnit = .weight,
        unitTwo: ExerciseUnit = .reps,
        sets: [Double]
    ) {
        self.id = UUID().uuidString
        self.listId = listId
        self.rpe = 5
        self.unitOne = unitOne
        self.unitTwo = unitTwo
        self.sets = sets.map { VinceraSet(reps: $0) }
    }

    func clone() -> Exercise {
        return Exercise(
            id: UUID().uuidString,
            listId: listId,
            rpe: rpe,
            unitOne: unitOne,
            unitTwo: unitTwo,
            sets: sets.map { $0.clone() }
        )
    }

    mutating func addSet() {
        sets.append(VinceraSet())
    }

    mutating func removeSet() {
        guard self.sets.count > 1 else { return }
        sets.removeLast()
    }

    func maxValue(for unit: ExerciseUnit) -> (Double, Double)? {
        if unitOne == unit { return sets.maxValue(.one) }
        if unitTwo == unit { return sets.maxValue(.two) }
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

    mutating func fillDown(_ index: Int) {
        guard canFillDown(index) else { return }
        sets[index+1].valueOne = sets[index].valueOne
        sets[index+1].valueTwo = sets[index].valueTwo
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Array<Array<Exercise>> {
    func flattened() -> [Exercise] {
        return self.flatMap { $0 }
    }
    
    func clone() -> [[Exercise]] {
        return self.map { $0.map { Exercise($0) } }
    }
    
    mutating func addExercises(_ listExercises: [ListExercise]) {
        self.append(contentsOf: listExercises.map { [Exercise($0)] })
    }
    
    func getBodyParts(_ store: ExerciseStore) -> String {
        return Set(self.flatMap { wrapper in
            wrapper.compactMap { exercise in
                store.getExercise(exercise.listId)?.bodyPart.capitalized
            }
        })
        .sorted()
        .joined(separator: ", ")
    }
    
    func getListIds() -> [String] {
        return self.flatMap({ $0.map({ $0.listId }) })
    }
    
    mutating func move(from source: IndexSet, to destination: Int) {
        self.move(fromOffsets: source, toOffset: destination)
    }
    
    mutating func remove(_ wrapper: [Exercise]) {
        guard let index = self.firstIndex(of: wrapper) else { return }
        self.remove(at: index)
    }
    
    func getVolume() -> Int {
        return self.reduce(0) { $0 + $1.reduce(0) { $0 + $1.sets.count } }
    }
    
    func getAverageRpe() -> Double {
        return self.reduce(0) { $0 + Double($1.getRpe() ?? 0) } / Double(self.count)
    }
}

extension Array<Exercise> {
    mutating func superset(_ listExercises: [ListExercise]) {
        self.append(contentsOf: listExercises.map { Exercise($0) })
    }
    
    mutating func replace(_ listExercises: [ListExercise]) {
        self = listExercises.map { Exercise($0) }
    }
    
    func getRpe() -> Int? {
        return self.first?.rpe
    }
    
    mutating func setRpe(_ rpe: Int) {
        for i in 0..<count {
            self[i].rpe = rpe
        }
    }
}

enum ExerciseUnit: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    var compressed: String {
        switch self {
        case .reps: "r"
        case .weight: "w"
        case .weightPlus: "p"
        case .time: "t"
        case .distance: "d"
        }
    }
    var icon: String {
        switch self {
        case .reps: "number"
        case .weight: "scalemass.fill"
        case .weightPlus: "scalemass.fill"
        case .time: "clock.fill"
        case .distance: "ruler.fill"
        }
    }
    var name: String { self.rawValue }
    var label: some View { Label(name, systemImage: icon) }
    
    static func fromCompressed(_ compressed: String) -> ExerciseUnit? {
        switch compressed {
        case "r": return .reps
        case "w": return .weight
        case "p": return .weightPlus
        case "t": return .time
        case "d": return .distance
        default: return nil
        }
    }
    
    case reps = "Reps"
    case weight = "Weight"
    case weightPlus = "Weight(+)"
    case time = "Time"
    case distance = "Distance"
}
