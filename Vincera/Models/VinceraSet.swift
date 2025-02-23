//
//  Set.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

struct VinceraSet: Codable, Identifiable, Hashable {
    var id: String
    var valueOne: Double?
    var valueTwo: Double?
    var type: SetType

    init(id: String, valueOne: Double? = nil, valueTwo: Double? = nil, type: SetType) {
        self.id = id
        self.valueOne = valueOne
        self.valueTwo = valueTwo
        self.type = type
    }

    init() {
        self.id = UUID().uuidString
        self.valueOne = nil
        self.valueTwo = nil
        self.type = SetType.normal
    }

    init(reps: Double, type: SetType = .normal) {
        self.id = UUID().uuidString
        self.valueOne = nil
        self.valueTwo = reps
        self.type = type
    }
    
    mutating func fillValues() {
        if valueOne == nil { valueOne = 0 }
        if valueTwo == nil { valueTwo = 0 }
    }

    func clone() -> VinceraSet {
        return VinceraSet(id: UUID().uuidString, valueOne: valueOne, valueTwo: valueTwo, type: type)
    }
}

enum SetType: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    
    case normal = "normal"
    case myo = "myo"
    case drop = "drop"
    case warmup = "warmup"
    case cooldown = "cooldown"
}

enum LLSetValueSelector {
    case one, two
}

extension Array<VinceraSet> {
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
