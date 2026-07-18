//
//  CodingKeys.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

extension V1.Split {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _description = "description"
        case _days = "days"
    }
    
    static func == (lhs: V1.Split, rhs: V1.Split) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension V1.Day {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _name = "name"
        case _description = "description"
        case _color = "color"
        case _exercises = "exercises"
    }
    
    static func == (lhs: V1.Day, rhs: V1.Day) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

extension V1.Workout {
    enum CodingKeys: String, CodingKey {
        case _id = "id"
        case _dayId = "dayId"
        case _name = "name"
        case _color = "color"
        case _start = "start"
        case _end = "end"
        case _exercises = "exercises"
    }
    
    static func == (lhs: V1.Workout, rhs: V1.Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
