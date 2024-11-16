//
//  Settings.swift
//  Vincera
//
//  Created by Matt Linder on 11/15/24.
//

import SwiftUI

struct SettingsView: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var wStore: WorkoutStore
  @State private var units: UnitSystem = .imperial
  
  var body: some View {
    Form {
      Picker("Weight Units", selection: $units) {
        ForEach(UnitSystem.allCases) {
          Text($0.rawValue).tag($0)
        }
      }
    }
    .navigationTitle("Settings")
    .onChange(of: units) { handleChange($1) }
  }
  
  func handleChange(_ newValue: UnitSystem) {
    do {
      switch newValue {
      case .imperial:
        try wStore.kgToLb()
        break
      case .metric:
        try wStore.lbToKg()
        break
      }
    } catch {
      router.notify(.danger, "Failed to update units")
    }
  }
}
