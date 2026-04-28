//
//  VinceraTests.swift
//  VinceraTests
//
//  Created by Matt Linder on 3/26/26.
//

import Testing
@testable import Vincera

struct VinceraTests {

    @Test func testSplitStringFormatting() async throws {
        let store = DataStore().mock()
        let result = VINCERA_SPLITS.first?.formattedFull(store)
        print(String(result ?? "nil"))
        #expect(result != nil)
    }

    @Test func testDecisionTree() {
        let store = DataStore().mock()
        let info = SplitInfo(
            sex: .female,
            days: .three,
            goal: .weightLoss,
            focus: [.glutes, .quads, .hams],
            equipment: EquipmentType.allCases
        )
        
        let split = SplitBuilder.build(info)
        let result = split.formattedFull(store)
        print(result)
        #expect(!result.isEmpty)
    }
}
