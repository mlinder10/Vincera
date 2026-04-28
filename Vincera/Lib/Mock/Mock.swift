//
//  Mock.swift
//  Vincera
//
//  Created by Matt Linder on 3/24/26.
//

import SwiftUI

let MOCK_DATA_STORE = DataStore().mock()
//let MOCK_DATA_STORE = DataStore()

let MOCK_SPLITS: [Writers.Split] = []

let MOCK_WORKOUTS: [Writers.Workout] = [
    .init(
        id: UUID().uuidString,
        name: "Test Workout - 1",
        description: "Some random description for a mock workout",
        color: Color.random().toHex(),
        wrappers: []
    ),
    .init(
        id: UUID().uuidString,
        name: "Test Workout - 2",
        description: "Some random description for a mock workout",
        color: Color.random().toHex(),
        wrappers: []
    ),
    .init(
        id: UUID().uuidString,
        name: "Test Workout - 3",
        description: "Some random description for a mock workout",
        color: Color.random().toHex(),
        wrappers: []
    ),
    .init(
        id: UUID().uuidString,
        name: "Test Workout - 4",
        description: "Some random description for a mock workout",
        color: Color.random().toHex(),
        wrappers: []
    ),
    .init(
        id: UUID().uuidString,
        name: "Test Workout - 5",
        description: "Some random description for a mock workout",
        color: Color.random().toHex(),
        wrappers: []
    )
]

let MOCK_COMPLETED_WORKOUTS: [Writers.CompletedWorkout] = [
    .init(
        id: UUID().uuidString,
        dayId: nil,
        name: "Test Workout - 1",
        notes: "",
        color: Color.random().toHex(),
        startedAt: Date().addingTimeInterval(-1 * 60 * 60 * 24),
        endedAt: Date(),
        wrappers: []
    )
]

let MOCK_SPLIT_META = Writers.SplitMeta(splitId: VINCERA_SPLITS.first?.id, dayIndex: 0)
