//
//  Products.swift
//  Vincera
//
//  Created by Matt Linder on 3/30/26.
//

import Foundation

let PREMIUM_SPLITS = [MATTS_SPLIT]

let NON_CONSUMABLE_PRODUCT_IDS: Set<String> = Set(PREMIUM_SPLITS.map({ $0.productId }))

// MARK: start premium splits

let MATTS_SPLIT = PremiumSplit(
    productId: "com.mattlinder.vincera.matts_split",
    split: .init(
        id: PREMIUM_SPLIT_PREFIX + "matts-split",
        name: "Matt's Split",
        description: "Push Pull Legs base split designed to focus hypertrophy training in the legs, arms, and calves. (optimal for taller lifters)",
        days: [
            .init(
                id: UUID().uuidString,
                name: "Push",
                description: "",
                color: "#ff0000",
                isRest: false,
                wrappers: [
                    .init([.init(listId: "1", sets: [6, 6])]),
                    .init([.init(listId: "9", sets: [8, 8])]),
                    .init([.init(listId: "105", sets: [10, 10])]),
                    .init([.init(listId: "31", sets: [10, 10])]),
                    .init([.init(listId: "32", sets: [10, 10])]),
                    .init([.init(listId: "18", sets: [12, 12, 12])]),
//                    .init([.init(listId: "hanging-leg-raise", sets: [10, 10])]),
//                    .init([.init(listId: "decline-crunch", sets: [12, 12])])
                ]
            ),
            .init(
                id: UUID().uuidString,
                name: "Pull",
                description: "",
                color: "#ff6600",
                isRest: false,
                wrappers: [
                    .init([.init(listId: "52", sets: [8, 8])]),
                    .init([.init(listId: "113", sets: [10, 10])]),
                    .init([.init(listId: "53", sets: [10, 10])]),
                    .init([.init(listId: "114", sets: [10, 10])]),
                    .init([.init(listId: "40", sets: [8, 8])]),
                    .init([.init(listId: "42", sets: [10, 10])]),
                    .init([.init(listId: "102", sets: [10, 10])]),
                ]
            ),
            .init(
                id: UUID().uuidString,
                name: "Legs",
                description: "",
                color: "#ffbb55",
                isRest: false,
                wrappers: [
                    .init([.init(listId: "58", sets: [6, 6])]),
                    .init([.init(listId: "68", sets: [8, 8])]),
                    .init([.init(listId: "63", sets: [8, 8])]),
                    .init([.init(listId: "70", sets: [10, 10])]),
                    .init([.init(listId: "101", sets: [12, 12])]),
                    .init([.init(listId: "90", sets: [15, 15])]),
                    .init([.init(listId: "84", sets: [15, 15, 15])])
                ]
            ),
            .init(
                id: UUID().uuidString,
                name: "Rest",
                description: "",
                color: "#000000",
                isRest: true,
                wrappers: []
            ),
        ]
    )
)


