//
//  VinceraTests.swift
//  VinceraTests
//
//  Created by Matt Linder on 3/26/26.
//

import Testing
import Foundation
@testable import Vincera

struct VinceraTests {
    
    private func getWritableDBURL(cleanup: Bool = false) -> URL {
        let fileManager = FileManager.default
        let cachesURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let dbURL = cachesURL.appendingPathComponent("test-embeddings.db")
        if cleanup { try? fileManager.removeItem(at: dbURL) }
        print("👉 Inspectable Database Path: \(dbURL.path)")
        return dbURL
    }

    @Test func testSplitStringFormatting() {
        let store = DataStore().mock()
        let result = VINCERA_SPLITS.first?.formattedFull(store)
        print(String(result ?? "nil"))
        #expect(result != nil)
    }

    @Test func testDecisionTree() {
        let store = DataStore().mock()
        let survey = SurveyData(
            heightInInches: 75,
            weightInLbs: 200,
            age: 21,
            gender: .male,
            activityLevel: .lightlyActive,
            goal: .fatLoss,
            targetMuscles: [],
            availableEquipment: EquipmentType.allCases,
            daysPerWeek: 6
        )
        
        let split = SplitBuilder.build(survey)
        let splitString = split.formattedFull(store)
        
        print(splitString)
        #expect(!splitString.isEmpty)
    }
}
