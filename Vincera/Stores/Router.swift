//
//  Router.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation
import SwiftUI

enum Tab {
  case workout, plan, history, exercises
}

private let NOTIFICATION_DURATION: CGFloat = 3 // seconds

enum Route: Hashable {
  case exercisePage(ListExercise)
  case exerciseList([String], ((ListExercise) -> Void)?, ([ListExercise]) -> Void)
  case splitEditor(Split?)
  case splitDayEditor(Binding<Day>)
  case dayEditor(Day?)
  case splitList
  case createPr
  case pastWorkout(Binding<Workout>)
  case createExercise
  case settings
}

@MainActor
final class Router: ObservableObject {
  @Published var tab: Tab = .workout
  @Published var workoutRoutes = [Route]()
  @Published var planRoutes = [Route]()
  @Published var historyRoutes = [Route]()
  @Published var exerciseRoutes = [Route]()
  @Published var activeWorkoutRoutes = [Route]()
  @Published var isShowingActiveWorkout = false
  @Published var details: Details? = nil
  @Published var dialog: Dialog? = nil
  @MainActor
  @Published var notification: Notification? = nil {
    didSet {
      if notification != nil {
        DispatchQueue.main.asyncAfter(deadline: .now() + NOTIFICATION_DURATION) {
          self.notification = nil
        }
      }
    }
  }
  
  
  var currentRoute: [Route] {
    get {
      if isShowingActiveWorkout { return activeWorkoutRoutes }
      return switch tab {
      case .workout: workoutRoutes
      case .plan: planRoutes
      case .history: historyRoutes
      case .exercises: exerciseRoutes
      }
    }
    set {
      if isShowingActiveWorkout {
        activeWorkoutRoutes = newValue
      } else {
        switch tab {
        case .workout: workoutRoutes = newValue
        case .plan: planRoutes = newValue
        case .history: historyRoutes = newValue
        case .exercises: exerciseRoutes = newValue
        }
      }
    }
  }
  
  func notify(_ type: NotificationType, _ message: String) {
    withAnimation {
      notification = Notification(message: message, type: type)
    }
  }
  
  func giveDetails(_ icon: String, _ title: String, _ description: String) {
    withAnimation {
      details = Details(icon: icon, title: title, description: description)
    }
  }
  
  func showDialog(_ text: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
    withAnimation {
      dialog = Dialog(text: text, role: role, action: action)
    }
  }
  
  func canGoBack() -> Bool { return !currentRoute.isEmpty }
  
  func goBack() { if canGoBack() { currentRoute.removeLast() } }
  
  func goTo(_ route: Route) { currentRoute.append(route) }
}

extension View {
  var rootNavigator: some View {
    self.modifier(RootNavigatorModifier())
  }
}

fileprivate struct RootNavigatorModifier: ViewModifier {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var wStore: WorkoutStore
  
  func body(content: Content) -> some View {
    content
      .navigationDestination(for: Route.self) { route in
        switch route {
        case .exercisePage(let exercise): ExercisePage(exercise: exercise)
        case .exerciseList(let hidden, let onTap, let onAdd): ExercisesTab(hidden, onTap: onTap, onAdd: onAdd)
        case .splitEditor(let split): SplitEditor(split)
        case .splitDayEditor(let day): SplitDayEditor(day: day)
        case .dayEditor(let day): DayEditor(day)
        case .splitList: SplitListPage()
        case .createPr: CreatePRTrackerPage()
        case .pastWorkout(let workout): PastWorkoutView(workout: workout)
        case .createExercise: CreateExercisePage()
        case .settings: SettingsView()
        }
      }
  }
}
