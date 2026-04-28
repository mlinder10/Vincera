//
//  Routes.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI

extension View {
    var navigator: some View {
        self
            .navigationDestination(for: AnyRoute.self) { $0.base.view() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        AccountScreen()
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
    }
}

struct ExercisePageRoute: Route {
    var stacks: [ProtectedStack] = [.exercise, .activeWorkout, .workout, .plan, .history]
    var name = "ExercisePage"
    let exercise: ListExercise
    
    func view() -> AnyView {
        AnyView(ExerciseScreen(exercise: exercise))
    }
}

struct ExerciseListRoute: Route {
    static func == (lhs: ExerciseListRoute, rhs: ExerciseListRoute) -> Bool {
        (
            lhs.hidden.sorted().joined() == rhs.hidden.sorted().joined() &&
            lhs.replacementId == rhs.replacementId
        )
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(hidden)
        hasher.combine(replacementId)
    }
    
    var stacks: [ProtectedStack] = [.workout, .plan, .exercise, .activeWorkout, .history]
    var name = "ExerciseList"
    let hidden: [String]
    let replacementId: String?
    let onTap: ((ListExercise) -> Void)?
    let onAdd: (([ListExercise]) -> Void)?
    
    func view() -> AnyView {
        AnyView(
            ExerciseListScreen(
                hidden,
                replacementId: replacementId,
                onTap: onTap,
                onAdd: onAdd
            )
        )
    }
}

struct SplitEditorRoute: Route {
    var stacks: [ProtectedStack] = [.plan]
    var name = "SplitEditor"
    let split: Writers.Split?
    
    func view() -> AnyView {
        AnyView(SplitEditor(split))
    }
}

struct SplitDayEditorRoute: Route {
    var stacks: [ProtectedStack] = [.plan]
    var name = "SplitEditor"
    let day: Builder.Day
    
    func view() -> AnyView {
        AnyView(SplitDayEditor(day: day))
    }
}

struct WorkoutEditorRoute: Route {
    var stacks: [ProtectedStack] = [.plan]
    var name = "DayEditor"
    let workout: Writers.Workout?
    
    func view() -> AnyView {
        AnyView(WorkoutEditor(workout))
    }
}

struct SplitListRoute: Route {
    var stacks: [ProtectedStack] = [.plan]
    var name = "SplitList"
    
    func view() -> AnyView {
        AnyView(SplitListScreen())
    }
}

struct CreatePRRoute: Route {
    var stacks: [ProtectedStack] = [.history]
    var name = "CreatePR"
    
    func view() -> AnyView {
        AnyView(CreatePRTrackerScreen())
    }
}

struct CompletedWorkoutRoute: Route {
    var stacks: [ProtectedStack] = [.history]
    var name = "PastWorkout"
    let workout: Writers.CompletedWorkout
    
    func view() -> AnyView {
        AnyView(CompletedWorkoutScreen(workout: workout))
    }
}

struct CreateExerciseRoute: Route {
    var stacks: [ProtectedStack] = [.plan, .workout, .activeWorkout, .history, .exercise]
    var name = "CreateExercise"
    
    func view() -> AnyView {
        AnyView(CreateExerciseScreen())
    }
}

struct AssistedSplitRoute: Route {
    var stacks: [ProtectedStack] = [.plan, .workout]
    var name = "AssistedSplit"
    
    func view() -> AnyView {
        AnyView(AssistedSplitScreen())
    }
}
