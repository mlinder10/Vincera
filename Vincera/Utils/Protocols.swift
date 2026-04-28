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
