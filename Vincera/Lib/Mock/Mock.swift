//
//  Mock.swift
//  Vincera
//
//  Created by Matt Linder on 3/24/26.
//

import SwiftUI

let MOCK_DATA_STORE = DataStore().mock()
//let MOCK_DATA_STORE = DataStore()

let MOCK_SURVEY_DATA = SurveyData(
    gender: .male,
    goal: .muscleGain,
    targetMuscles: [.sideDelts, .bis, .tris],
    availableEquipment: EquipmentType.allCases,
    daysPerWeek: 6
)

let MOCK_SPLITS: [Writers.Split] = []

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

let MOCK_TRACKERS: [Writers.PRTracker] = [
    .init(listId: "0", type: .weight),
    .init(listId: "51", type: .reps)
]

let MOCK_SPLIT_META = Writers.SplitMeta(splitId: VINCERA_SPLITS.first?.id, dayIndex: 0)
