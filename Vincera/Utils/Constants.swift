//
//  Constants.swift
//  Vincera
//
//  Created by Matt Linder on 10/26/24.
//

import Foundation

let PADDING_INLINE: CGFloat = 24
let PADDING_TOP: CGFloat = 16

let VINCERA_SPLIT_PREFIX = "vincera-"
let PREMIUM_SPLIT_PREFIX = "vincera-premium-"

// MARK: exercise

let UNKNOWN_LIST_EXERCISE = ListExercise(
    id: "unknown-exercise",
    name: "Unknown",
    description: "",
    directions: [],
    cues: [],
    image: "",
    videoUrl: "",
    bodyPart: "",
    primaryGroup: "",
    secondaryGroups: [],
    exerciseType: "",
    equipmentType: "",
    unitsOne: .weight,
    unitsTwo: .reps,
    repsLow: 0,
    repsHigh: 0,
    stimulus: 1,
    fatigue: 1
)

// MARK: start built in splits

func isSplitImmutable(splitId: String) -> Bool {
    isSplitBuiltin(splitId: splitId) ||
    isSplitPremium(splitId: splitId)
}

func isSplitBuiltin(splitId: String) -> Bool {
    VINCERA_SPLITS.contains(where: { $0.id == splitId })
}

func isSplitPremium(splitId: String) -> Bool {
    PREMIUM_SPLITS.contains(where: { $0.id == splitId })
}

let VINCERA_SPLITS = [PPL, UL, FB]

let PPL = Writers.Split(
  id: VINCERA_SPLIT_PREFIX + "PUSH_PULL_LEGS",
  name: "Push Pull Legs",
  description: "Three day split geard towards those looking for growth in both size and strength",
  days: [
    .init(
      id: UUID().uuidString,
      name: "Push",
      description: "Strength and hypertrophy centered chest, shoulders, and triceps workout",
      color: "#dd0000",
      isRest: false,
      wrappers: [
        .init([.init(listId: "0", sets: [6, 6, 6])]), // Flat Bench),
        .init([.init(listId: "1", sets: [10, 10, 10])]), // Incline Bench
        .init([.init(listId: "33", sets: [12, 12, 12])]), // Cable Pushdown
        .init([.init(listId: "31", sets: [12, 12, 12])]), // Overhead Extension
        .init([
            .init(listId: "18", sets: [15, 15, 15]), // Lat Raise
            .init(listId: "24", sets: [10, 10, 10]) // Rear Delt Fly
        ])
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Pull",
      description: "Hypertrophy focused back and bicep workout with a focus on lats",
      color: "#0000ee",
      isRest: false,
      wrappers: [
        .init([.init(listId: "52", sets: [8, 8, 8])]), // Lat Pulldown
        .init([.init(listId: "53", sets: [12, 12, 12])]), // Cable Row
        .init([.init(listId: "80", sets: [15, 15, 15])]), // Pullover
        .init([.init(listId: "42", sets: [12, 12, 12])]), // Dumbbell Decline Curl
        .init([.init(listId: "40", sets: [12, 12, 12])]) // Dumbbell Hammer Curl
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Legs",
      description: "Hypertrophy focused leg workout",
      color: "#aa00dd",
      isRest: false,
      wrappers: [
        .init([.init(listId: "68", sets: [8, 8, 8])]), // Hack Squat
        .init([.init(listId: "58", sets: [8, 8, 8])]), // Stiff-Legged Deadlift
        .init([.init(listId: "70", sets: [12, 12, 12])]), // Leg Extension
        .init([.init(listId: "63", sets: [12, 12, 12])]), // Seated Leg Curl
        .init([.init(listId: "81", sets: [15, 15, 15])]) // Seated Calf Raise
      ]
    ),
  ]
)

let UL = Writers.Split(
  id: VINCERA_SPLIT_PREFIX + "UPPER_LOWER",
  name: "Upper Lower",
  description: "A four-day split alternating between upper and lower body workouts, ideal for balanced strength and muscle growth.",
  days: [
    .init(
      id: UUID().uuidString,
      name: "Upper A",
      description: "A strength-focused upper body workout targeting the chest, back, shoulders, and arms.",
      color: "#ee8822",
      isRest: false,
      wrappers: [
        .init([.init(listId: "1", sets: [10, 10, 10])]), // Incline Bench Press
        .init([.init(listId: "52", sets: [10, 10])]), // Lat Pulldown
        .init([.init(listId: "34", sets: [12, 12, 12])]), // Close Grip Bench Press
        .init([.init(listId: "53", sets: [12, 12])]), // Cable Row
        .init([.init(listId: "44", sets: [15, 15, 15])]), // Cable Curl
        .init([.init(listId: "88", sets: [15, 15, 15])]) // Cable Lat Raise
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Lower A",
      description: "A lower body workout designed to build strength and endurance in the legs and glutes.",
      color: "#ffdd11",
      isRest: false,
      wrappers: [
        .init([.init(listId: "68", sets: [12, 12, 12])]), // Hack Squat
        .init([.init(listId: "63", sets: [15, 15, 15])]), // Seated Leg Curl
        .init([.init(listId: "70", sets: [15, 15, 15])]), // Leg Extension
        .init([.init(listId: "81", sets: [20, 20])]) // Seated Calf Raise
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Upper B",
      description: "A hypertrophy-focused upper body workout with an emphasis on compound and isolation movements.",
      color: "#22cc22",
      isRest: false,
      wrappers: [
        .init([.init(listId: "48", sets: [10, 10, 10])]), // Overhand Bent Row
        .init([.init(listId: "76", sets: [10, 10])]), // Dumbbell Bench Press
        .init([.init(listId: "25", sets: [12, 12])]), // Machine Shoulder Press
        .init([.init(listId: "38", sets: [12, 12, 12])]), // Barbell Curl
        .init([.init(listId: "31", sets: [15, 15, 15])]) // Cable Overhead Extension
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Lower B",
      description: "A lower body session focused on muscle development and stability with key leg movements.",
      color: "#118833",
      isRest: false,
      wrappers: [
        .init([.init(listId: "58", sets: [12, 12, 12])]), // Stiff-Legged Deadlift
        .init([.init(listId: "70", sets: [15, 15, 15])]), // Leg Extension
        .init([.init(listId: "63", sets: [15, 15, 15])]), // Seated Leg Curl
        .init([.init(listId: "84", sets: [20, 20])]) // Leg Press Calf Raise
      ]
    )
  ]
)

let FB = Writers.Split(
  id: VINCERA_SPLIT_PREFIX + "FULL_BODY",
  name: "Full Body",
  description: "A three-day split that trains the entire body in each session, perfect for maximizing efficiency and recovery.",
  days: [
    .init(
      id: UUID().uuidString,
      name: "Full Body 1",
      description: "A balanced full-body workout emphasizing compound lifts for overall strength.",
      color: "#dddddd",
      isRest: false,
      wrappers: [
        .init([.init(listId: "0", sets: [8, 8, 8])]), // Bench Press
        .init([.init(listId: "68", sets: [10, 10, 10])]), // Hack Squat
        .init([.init(listId: "52", sets: [12, 12, 12])]), // Lat Pulldown
        .init([.init(listId: "63", sets: [12, 12, 12])]), // Seated Leg Curl
        .init([.init(listId: "42", sets: [12, 12, 12])]), // Dumbbell Decline Curl
        .init([.init(listId: "18", sets: [15, 15, 15])]) // Lat Raise
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Full Body 2",
      description: "A strength and endurance-focused full-body session incorporating key compound movements.",
      color: "#676767",
      isRest: false,
      wrappers: [
        .init([.init(listId: "51", sets: [10, 10, 10])]), // Pull Up
        .init([.init(listId: "58", sets: [10, 10, 10])]), // Stiff-Legged Deadlift
        .init([.init(listId: "77", sets: [10, 10, 10])]), // Incline Dumbbell Bench Press
        .init([.init(listId: "90", sets: [10, 10, 10])]), // Smith Machine Squat
        .init([.init(listId: "32", sets: [12, 12, 12])]), // Cable Rope Pulldown
        .init([.init(listId: "18", sets: [15, 15, 15])]) // Lat Raise
      ]
    ),
    .init(
      id: UUID().uuidString,
      name: "Full Body 3",
      description: "A full-body hypertrophy workout designed to build muscle and improve overall conditioning.",
      color: "#222222",
      isRest: false,
      wrappers: [
        .init([.init(listId: "66", sets: [10, 10, 10])]), // High Bar Squat
        .init([.init(listId: "53", sets: [12, 12, 12])]), // Cable Row
        .init([.init(listId: "63", sets: [12, 12, 12])]), // Seated Leg Curl
        .init([.init(listId: "107", sets: [10, 10, 10])]), // Incline Chest Press
        .init([.init(listId: "40", sets: [12, 12, 12])]), // Dumbbell Hammer Curl
        .init([.init(listId: "31", sets: [12, 12, 12])]) // Cable Overhead Extension
      ]
    )
  ]
)
