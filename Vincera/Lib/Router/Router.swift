//
//  Router.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import Foundation
import SwiftUI

final class Router: ObservableObject {
    static let shared = Router()
    
    private init() {}
    
    @Published var isOnboarded = isOnboardingComplete()
    @Published var showRatingScreen = false
    
    @Published var tab: ProtectedTab = .workout
    @Published var showWorkout = false
    @Published var routes = Routes()
    @Published var toast: ToastData?
    
    var currentStack: ProtectedStack {
        if self.showWorkout { return .activeWorkout }
        return self.tab.stack
    }
    var currentRoutes: [AnyRoute] {
        get { self.routes.select(stack: self.currentStack) }
        set { self.routes.update(at: self.currentStack, newValue) }
    }
    
    func push(_ route: any Route) {
        if !route.stacks.contains(self.currentStack) {
            guard let target = route.stacks.first else {
                fatalError("Route with no associated stacks: " + route.name)
            }
            if target == .activeWorkout {
                self.showWorkout = true
            } else if currentStack == .activeWorkout {
                self.showWorkout = false
            } else {
                self.tab = target.tab
            }
        }
        currentRoutes.append(AnyRoute(route))
    }
    
    func pop() {
        if !currentRoutes.isEmpty {
            currentRoutes.removeLast()
        }
    }
    
    func toast(_ title: String, subtitle: String? = nil, type: ToastType = .info) {
        withAnimation {
            self.toast = ToastData(type: type, title: title, subtitle: subtitle)
        }
    }
}

enum ProtectedTab {
    case workout, history, library, settings
    
    var stack: ProtectedStack {
        return switch self {
        case .workout: .workout
        case .history: .history
        case .library: .library
        case .settings: .settings
        }
    }
}

enum ProtectedStack {
    case workout, history, library, settings, activeWorkout
    
    var tab: ProtectedTab {
        return switch self {
        case .workout: .workout
        case .history: .history
        case .library: .library
        case .settings: .settings
        case .activeWorkout: fatalError("Attempted to convert ProtectedStack to ProtectedTab on activeWorkout")
        }
    }
}

struct Routes {
    var workout = [AnyRoute]()
    var history = [AnyRoute]()
    var library = [AnyRoute]()
    var settings = [AnyRoute]()
    var activeWorkout = [AnyRoute]()
    
    func select(stack: ProtectedStack) -> [AnyRoute] {
        return switch stack {
        case .workout: workout
        case .history: history
        case .library: library
        case .settings: settings
        case .activeWorkout: activeWorkout
        }
    }
    
    mutating func update(at stack: ProtectedStack, _ newValue: [AnyRoute]) {
        switch stack {
        case .workout: workout = newValue
        case .history: history = newValue
        case .library: library = newValue
        case .settings: settings = newValue
        case .activeWorkout: activeWorkout = newValue
        }
    }
}

protocol Route: Hashable {
    var stacks: [ProtectedStack] { get }
    var name: String { get }
    
    func view() -> AnyView
}

struct AnyRoute: Hashable {
    let base: any Route

    init(_ route: any Route) {
        self.base = route
    }

    static func == (lhs: AnyRoute, rhs: AnyRoute) -> Bool {
        AnyHashable(lhs.base) == AnyHashable(rhs.base)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(AnyHashable(base))
    }
}
