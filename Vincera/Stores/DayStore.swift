//
//  DayStore.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import Foundation

final class DayStore: ObservableObject {
  @Published var days: [Day]
  
  init() {
    let days: [Day]? = try? StorageManager.shared.read(.days)
    self.days = days ?? []
  }
  
  func createDay(_ day: Day) throws {
    days.insert(day, at: 0)
    do {
      try StorageManager.shared.write(.days, days)
    } catch {
      days.removeFirst()
      throw error
    }
  }
  
  func editDay(_ day: Day) throws {
    guard let index = days.firstIndex(where: { $0.id == day.id }) else { return }
    let original = days[index]
    days[index] = day
    do {
      try StorageManager.shared.write(.days, days)
    } catch {
      days[index] = original
      throw error
    }
  }
  
  func deleteDay(_ day: Day) throws {
    guard let index = days.firstIndex(where: { $0.id == day.id }) else { return }
    days.remove(at: index)
    do {
      try StorageManager.shared.write(.days, days)
    } catch {
      days.insert(day, at: index)
      throw error
    }
  }
}
