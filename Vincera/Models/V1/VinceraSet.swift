//
//  Set.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

extension V1 {
    struct VinceraSet: Codable, Identifiable, Equatable {
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
        
        func clone() -> VinceraSet {
            return VinceraSet(id: UUID().uuidString, valueOne: valueOne, valueTwo: valueTwo, type: type)
        }
        
        mutating func fillValues() {
            if valueOne == nil { valueOne = 0 }
            if valueTwo == nil { valueTwo = 0 }
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: VinceraSet, rhs: VinceraSet) -> Bool {
            lhs.id == rhs.id
        }
    }
}


    
    

extension Array<V1.VinceraSet> {
    func maxValue(_ value: SetValueSelector) -> (Double, Double)? {
        let first = self
            .compactMap({ value == .one ? $0.valueOne : $0.valueTwo })
            .max()
        let second = value == .one ?
            self.first(where: { $0.valueOne == first })?.valueTwo :
            self.first(where: { $0.valueTwo == first})?.valueOne
        return (first ?? 0, second ?? 0)
    }
}
