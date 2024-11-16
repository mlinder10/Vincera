//
//  Constants.swift
//  Vincera
//
//  Created by Matt Linder on 10/26/24.
//

import Foundation

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
      color: "#ff0000",
      exercises: [
        [Exercise(listId: "0", sets: [6, 6, 6])],
        [Exercise(listId: "1", sets: [10, 10, 10])],
        [Exercise(listId: "33", sets: [12, 12, 12])],
        [Exercise(listId: "31", sets: [12, 12, 12])],
        [
          Exercise(listId: "18", sets: [15, 15, 15]),
          Exercise(listId: "24", sets: [10, 10, 10])
        ]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Pull",
      description: "Hypertrophy focused back and bicep workout with a focus on lats",
      color: "#0000ff",
      exercises: [
        [Exercise(listId: "52", sets: [8, 8, 8])],
        [Exercise(listId: "53", sets: [12, 12, 12])],
        [Exercise(listId: "80", sets: [15, 15, 15])],
        [Exercise(listId: "42", sets: [12, 12, 12])],
        [Exercise(listId: "40", sets: [12, 12, 12])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Legs",
      description: "Hypertrophy focused leg workout",
      color: "#ff00ff",
      exercises: [
        [Exercise(listId: "68", sets: [8, 8, 8])],
        [Exercise(listId: "58", sets: [8, 8, 8])],
        [Exercise(listId: "70", sets: [12, 12, 12])],
        [Exercise(listId: "63", sets: [12, 12, 12])],
        [Exercise(listId: "81", sets: [15, 15, 15])]
      ]
    ),
  ]
)

@MainActor
let UL = Split(
  id: "UPPER_LOWER",
  name: "Upper Lower",
  description: "",
  days: [
    Day(
      id: UUID().uuidString,
      name: "Upper A",
      description: "",
      color: "#ff00ff",
      exercises: [
        [Exercise(listId: "1", sets: [10, 10, 10])],
        [Exercise(listId: "52", sets: [10, 10])],
        [Exercise(listId: "34", sets: [12, 12, 12])],
        [Exercise(listId: "53", sets: [12, 12])],
        [Exercise(listId: "44", sets: [15, 15, 15])],
        [Exercise(listId: "88", sets: [15, 15, 15])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Lower A",
      description: "",
      color: "#ff00ff",
      exercises: [
        [Exercise(listId: "68", sets: [12, 12, 12])],
        [Exercise(listId: "63", sets: [15, 15, 15])],
        [Exercise(listId: "70", sets: [15, 15, 15])],
        [Exercise(listId: "81", sets: [20, 20])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Upper B",
      description: "",
      color: "#ff00ff",
      exercises: [
        [Exercise(listId: "48", sets: [10, 10, 10])],
        [Exercise(listId: "76", sets: [10, 10])],
        [Exercise(listId: "25", sets: [12, 12])],
        [Exercise(listId: "38", sets: [12, 12, 12])],
        [Exercise(listId: "31", sets: [15, 15, 15])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Lower B",
      description: "",
      color: "#ff00ff",
      exercises: [
        [Exercise(listId: "58", sets: [12, 12, 12])],
        [Exercise(listId: "70", sets: [15, 15, 15])],
        [Exercise(listId: "63", sets: [15, 15, 15])],
        [Exercise(listId: "84", sets: [20, 20])]
      ]
    )
  ]
)

@MainActor
let FB = Split(
  id: "FULL_BODY",
  name: "Full Body",
  description: "",
  days: [
    Day(
      id: UUID().uuidString,
      name: "Full Body 1",
      description: "",
      color: "#ff00ff",
      exercises: [
        // 0, 68, 52, 63, 42, 18
        [Exercise(listId: "0", sets: [8, 8, 8])],
        [Exercise(listId: "68", sets: [10, 10, 10])],
        [Exercise(listId: "52", sets: [12, 12, 12])],
        [Exercise(listId: "63", sets: [12, 12, 12])],
        [Exercise(listId: "42", sets: [12, 12, 12])],
        [Exercise(listId: "18", sets: [15, 15, 15])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Full Body 2",
      description: "",
      color: "#ff00ff",
      exercises: [
        // 51, 58, 77, 90, 32, 18
        [Exercise(listId: "51", sets: [10, 10, 10])],
        [Exercise(listId: "58", sets: [10, 10, 10])],
        [Exercise(listId: "77", sets: [10, 10, 10])],
        [Exercise(listId: "90", sets: [10, 10, 10])],
        [Exercise(listId: "32", sets: [12, 12, 12])],
        [Exercise(listId: "18", sets: [15, 15, 15])]
      ]
    ),
    Day(
      id: UUID().uuidString,
      name: "Full Body 3",
      description: "",
      color: "#ff00ff",
      exercises: [
        // 66, 53, 63, 107, 40, 31
        [Exercise(listId: "66", sets: [10, 10, 10])],
        [Exercise(listId: "53", sets: [12, 12, 12])],
        [Exercise(listId: "63", sets: [12, 12, 12])],
        [Exercise(listId: "107", sets: [10, 10, 10])],
        [Exercise(listId: "40", sets: [12, 12, 12])],
        [Exercise(listId: "31", sets: [12, 12, 12])]
      ]
    ),
  ]
)
