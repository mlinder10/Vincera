//
//  Models.swift
//  Vincera
//
//  Created by Matt Linder on 7/16/26.
//

import SwiftUI
    
protocol AppModel: Codable, Identifiable {}

@Observable
final class SplitMeta: Codable {
    var splitID: String?
    var dayIndex: Int?
}

@Observable
final class Split: AppModel {
    
}

@Observable
final class Day: AppModel {
    
}

@Observable
final class Wrapper: AppModel {
    let id: String
    var rpe: Int
    var exercises: [Exercise]
}

@Observable
final class Exercise: AppModel {
    let id: String
    var listID: String
    var sets: [_Set]
}

@Observable
final class _Set: AppModel {
    let id: String
    var valueOne: Double
    var valueTwo: Double
    var type: SetType
}
    
@Observable
final class Workout: AppModel {
    
}

@Observable
final class ActiveWorkout: AppModel {
    
}
