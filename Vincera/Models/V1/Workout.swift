//
//  Workout.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

@Observable
final class Workout: Codable, Identifiable, Hashable {
    var id: String
    var dayId: String
    var name: String
    var color: String
    var start: Date
    var end: Date?
    var exercises: [[Exercise]]
    
    init(id: String, dayId: String, name: String, color: String, start: Date, end: Date? = nil, exercises: [[Exercise]]) {
        self.id = id
        self.dayId = dayId
        self.name = name
        self.color = color
        self.start = start
        self.end = end
        self.exercises = exercises
    }
    
    init(_ day: Day?) {
        self.id = UUID().uuidString
        self.dayId = day?.id ?? ""
        self.name = day?.name ?? "Empty"
        self.color = day?.color ?? Color.random().toHex()
        self.start = Date()
        self.end = nil
        self.exercises = day?.exercises.clone() ?? []
    }
    
    func progress() -> Double {
        let setCount = Double(exercises.reduce(0) { $0 + $1.reduce(0) { $0 + $1.sets.count } })
        if setCount == 0 { return 0.0 }
        let completed = Double(exercises.reduce(0) { $0 + $1.reduce(0) { $0 + $1.sets.filter({ $0.valueOne != nil && $0.valueTwo != nil }).count } })
        return completed / setCount
    }
    
    func getMinutes() -> Int {
        guard let end else { return 0 }
        return Int(end.timeIntervalSince(start)) / 60
    }
    
    func isValid() -> Bool {
        return self.exercises.reduce(true) { $0 && $1.reduce(true) { $0 && $1.sets.reduce(true) { $1.valueOne != nil && $1.valueTwo != nil } } }
    }
    
    func fillEmpty() {
        for i in 0..<exercises.count {
            for j in 0..<exercises[i].count {
                for k in 0..<exercises[i][j].sets.count {
                    exercises[i][j].sets[k].fillValues()
                }
            }
        }
    }
}

extension Array<Workout> {
    func sortedByDate() -> [Workout] {
        return sorted { $0.start > $1.start }
    }
}
