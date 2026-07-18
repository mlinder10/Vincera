//
//  ExerciseScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 4/17/24.
//

import SwiftUI

private enum ExerciseScreenTab: CaseIterable, Identifiable {
    var id: Self { self }
    
    case details, history
    
    var label: String {
        switch self {
        case .details: "Details"
        case .history: "History"
        }
    }
}

struct ExerciseScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var tab: ExerciseScreenTab = .details
    let exercise: ListExercise
    
    
    var body: some View {
        ScrollView {
            VStack {
                ExerciseHeaderView(
                    name: exercise.name,
                    leftImg: exercise.image + "-contracted",
                    rightImg: exercise.image + "-extended",
                    videoUrl: exercise.videoUrl
                )
                
                Picker("Tab", selection: $tab) {
                    ForEach(ExerciseScreenTab.allCases) {
                        Text($0.label)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                switch tab {
                case .details:
                    ExerciseDetailsView(
                        description: exercise.description,
                        directions: exercise.directions,
                        cues: exercise.cues
                    )
                case .history:
                    ExerciseHistoryView(
                        exercise: exercise
                    )
                }
                
                if exercise.isCustom {
                    DeleteButtonView(exercise: exercise)
                }
            }
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .hiddenNavigation
    }
}

private struct DeleteButtonView: View {
    let exercise: ListExercise
    
    var body: some View {
        BrandButton("Delete Exercise", role: .destructive, action: handleDelete)
            .withAlert(title: "Confirm Delete")
            .primary
            .padding()
    }
    
    private func handleDelete() {
        do {
            try ExerciseList.shared.deleteExercise(exercise)
        } catch {
            Router.shared.toast("Error deleting \(exercise.name)", type: .error)
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseScreen(
            exercise: ListExercise(
                id: UUID().uuidString,
                name: "Bench Press",
                description: "",
                directions: [],
                cues: [],
                image: "bench-press",
                videoUrl: "",
                bodyPart: "Chest",
                primaryGroup: "pectorals",
                secondaryGroups: ["triceps", "front delts"],
                exerciseType: "compound",
                equipmentType: "barbell",
                unitsOne: .weight,
                unitsTwo: .reps,
                repsLow: 2,
                repsHigh: 8,
                stimulus: 1,
                fatigue: 1,
            )
        )
    }
}
