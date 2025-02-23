//
//  Day.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

@Observable
final class Day: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var description: String
    var color: String
    var exercises: [[Exercise]]
    
    init(id: String, name: String, description: String, color: String, exercises: [[Exercise]]) {
        self.id = id
        self.name = name
        self.description = description
        self.color = color
        self.exercises = exercises
    }
    
    init(_ name: String? = nil) {
        self.id = UUID().uuidString
        self.name = name ?? ""
        self.description = ""
        self.color = Color.random().toHex()
        self.exercises = []
    }
    
    func clone() -> Day {
        return Day(id: UUID().uuidString, name: name, description: description, color: color, exercises: exercises.map { $0.map { $0.clone() } })
    }
    
    func cloneWithUUID() -> Day {
        return Day(id: id, name: name, description: description, color: color, exercises: exercises.map { $0.map { $0.clone() } })
    }
}
