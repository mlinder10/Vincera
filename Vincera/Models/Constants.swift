//
//  Constants.swift
//  Vincera
//
//  Created by Matt Linder on 10/26/24.
//

import Foundation

nonisolated let UUID_SIZE: Int = UUID().uuidString.count

// MARK: start built in splits

@MainActor
let VINCERA_SPLITS = [PPL, UL, FB]

@MainActor
let PPL = Split(
  id: "PUSH_PULL_LEGS",
  name: "Push Pull Legs",
  description: "Three day split geard towards those looking for growth in both size and strength",
  days: [
    Day(
      id: UUID().uuidString,
      name: "Push",
      description: "Strength and hypertrophy centered chest, shoulders, and triceps workout",
      color: "#dd0000",
      exercises: [
        [Exercise(listId: "0", sets: [6, 6, 6])], // Flat Bench
        [Exercise(listId: "1", sets: [10, 10, 10])], // Incline Bench
        [Exercise(listId: "33", sets: [12, 12, 12])], // Cable Pushdown
        [Exercise(listId: "31", sets: [12, 12, 12])], // Overhead Extension
        [
          Exercise(listId: "18", sets: [15, 15, 15]), // Lat Raise
          Exercise(listId: "24", sets: [10, 10, 10]) // Rear Delt Fly
        ]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Pull",
      description: "Hypertrophy focused back and bicep workout with a focus on lats",
      color: "#0000ee",
      exercises: [
        [Exercise(listId: "52", sets: [8, 8, 8])], // Lat Pulldown
        [Exercise(listId: "53", sets: [12, 12, 12])], // Cable Row
        [Exercise(listId: "80", sets: [15, 15, 15])], // Pullover
        [Exercise(listId: "42", sets: [12, 12, 12])], // Dumbbell Decline Curl
        [Exercise(listId: "40", sets: [12, 12, 12])] // Dumbbell Hammer Curl
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Legs",
      description: "Hypertrophy focused leg workout",
      color: "#aa00dd",
      exercises: [
        [Exercise(listId: "68", sets: [8, 8, 8])], // Hack Squat
        [Exercise(listId: "58", sets: [8, 8, 8])], // Stiff-Legged Deadlift
        [Exercise(listId: "70", sets: [12, 12, 12])], // Leg Extension
        [Exercise(listId: "63", sets: [12, 12, 12])], // Seated Leg Curl
        [Exercise(listId: "81", sets: [15, 15, 15])] // Seated Calf Raise
      ]
    ),
  ]
)

@MainActor let UL = Split(
  id: "UPPER_LOWER",
  name: "Upper Lower",
  description: "A four-day split alternating between upper and lower body workouts, ideal for balanced strength and muscle growth.",
  days: [
    Day(
      id: UUID().uuidString,
      name: "Upper A",
      description: "A strength-focused upper body workout targeting the chest, back, shoulders, and arms.",
      color: "#ee8822",
      exercises: [
        [Exercise(listId: "1", sets: [10, 10, 10])], // Incline Bench Press
        [Exercise(listId: "52", sets: [10, 10])], // Lat Pulldown
        [Exercise(listId: "34", sets: [12, 12, 12])], // Close Grip Bench Press
        [Exercise(listId: "53", sets: [12, 12])], // Cable Row
        [Exercise(listId: "44", sets: [15, 15, 15])], // Cable Curl
        [Exercise(listId: "88", sets: [15, 15, 15])] // Cable Lat Raise
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Lower A",
      description: "A lower body workout designed to build strength and endurance in the legs and glutes.",
      color: "#ffdd11",
      exercises: [
        [Exercise(listId: "68", sets: [12, 12, 12])], // Hack Squat
        [Exercise(listId: "63", sets: [15, 15, 15])], // Seated Leg Curl
        [Exercise(listId: "70", sets: [15, 15, 15])], // Leg Extension
        [Exercise(listId: "81", sets: [20, 20])] // Seated Calf Raise
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Upper B",
      description: "A hypertrophy-focused upper body workout with an emphasis on compound and isolation movements.",
      color: "#22cc22",
      exercises: [
        [Exercise(listId: "48", sets: [10, 10, 10])], // Overhand Bent Row
        [Exercise(listId: "76", sets: [10, 10])], // Dumbbell Bench Press
        [Exercise(listId: "25", sets: [12, 12])], // Machine Shoulder Press
        [Exercise(listId: "38", sets: [12, 12, 12])], // Barbell Curl
        [Exercise(listId: "31", sets: [15, 15, 15])] // Cable Overhead Extension
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Lower B",
      description: "A lower body session focused on muscle development and stability with key leg movements.",
      color: "#118833",
      exercises: [
        [Exercise(listId: "58", sets: [12, 12, 12])], // Stiff-Legged Deadlift
        [Exercise(listId: "70", sets: [15, 15, 15])], // Leg Extension
        [Exercise(listId: "63", sets: [15, 15, 15])], // Seated Leg Curl
        [Exercise(listId: "84", sets: [20, 20])] // Leg Press Calf Raise
      ]
    )
  ]
)

@MainActor
let FB = Split(
  id: "FULL_BODY",
  name: "Full Body",
  description: "A three-day split that trains the entire body in each session, perfect for maximizing efficiency and recovery.",
  days: [
    Day(
      id: UUID().uuidString,
      name: "Full Body 1",
      description: "A balanced full-body workout emphasizing compound lifts for overall strength.",
      color: "#dddddd",
      exercises: [
        [Exercise(listId: "0", sets: [8, 8, 8])], // Bench Press
        [Exercise(listId: "68", sets: [10, 10, 10])], // Hack Squat
        [Exercise(listId: "52", sets: [12, 12, 12])], // Lat Pulldown
        [Exercise(listId: "63", sets: [12, 12, 12])], // Seated Leg Curl
        [Exercise(listId: "42", sets: [12, 12, 12])], // Dumbbell Decline Curl
        [Exercise(listId: "18", sets: [15, 15, 15])] // Lat Raise
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Full Body 2",
      description: "A strength and endurance-focused full-body session incorporating key compound movements.",
      color: "#676767",
      exercises: [
        [Exercise(listId: "51", sets: [10, 10, 10])], // Pull Up
        [Exercise(listId: "58", sets: [10, 10, 10])], // Stiff-Legged Deadlift
        [Exercise(listId: "77", sets: [10, 10, 10])], // Incline Dumbbell Bench Press
        [Exercise(listId: "90", sets: [10, 10, 10])], // Smith Machine Squat
        [Exercise(listId: "32", sets: [12, 12, 12])], // Cable Rope Pulldown
        [Exercise(listId: "18", sets: [15, 15, 15])] // Lat Raise
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Full Body 3",
      description: "A full-body hypertrophy workout designed to build muscle and improve overall conditioning.",
      color: "#222222",
      exercises: [
        [Exercise(listId: "66", sets: [10, 10, 10])], // High Bar Squat
        [Exercise(listId: "53", sets: [12, 12, 12])], // Cable Row
        [Exercise(listId: "63", sets: [12, 12, 12])], // Seated Leg Curl
        [Exercise(listId: "107", sets: [10, 10, 10])], // Incline Chest Press
        [Exercise(listId: "40", sets: [12, 12, 12])], // Dumbbell Hammer Curl
        [Exercise(listId: "31", sets: [12, 12, 12])] // Cable Overhead Extension
      ]
    )
  ]
)

// MARK: start premium splits

@MainActor
let PREMIUM_SPLITS = [MATTS_SPLIT]

@MainActor
let MATTS_SPLIT = PremiumSplit(
    productId: "matts-split",
    price: 0.99,
    split: Split(
        id: "MATTS_SPLIT",
        name: "Matt's Split",
        description: "Push Pull Legs base split designed to focus hypertrophy training in the legs, arms, and calves. (optimal for taller lifters)",
        days: []
    )
)
