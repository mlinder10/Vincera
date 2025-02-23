//
//  SplitStore.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import Foundation

final class SplitStore: ObservableObject {
    @Published var splits: [Split]
    @Published var current: Split?
    @Published var day: Day?
    @Published var meta: SplitMeta
    
    @MainActor
    init() {
        let splits: [Split]? = try? StorageManager.shared.read(.splits)
        self.splits = splits ?? []
        let meta: SplitMeta? = try? StorageManager.shared.read(.splitMeta)
        self.meta = meta ?? SplitMeta(splitId: nil, dayIndex: nil)
        current = VINCERA_SPLITS.first { $0.id == self.meta.splitId } ?? splits?.first { $0.id == self.meta.splitId }
        if let current {
            if let dayIndex = self.meta.dayIndex {
                day = current.days[dayIndex]
            } else {
                day = current.days.first
            }
        }
    }
    
    func createSplit(_ split: Split) throws {
        splits.insert(split, at: 0)
        do {
            try StorageManager.shared.write(.splits, splits)
            if current == nil {
                try? selectSplit(split)
            }
        } catch {
            splits.removeFirst()
            throw error
        }
    }
    
    func editSplit(_ split: Split) throws {
        if split.isBuiltin() {
            try createSplit(split.clone())
            return
        }
        guard let index = splits.firstIndex(where: { $0.id == split.id }) else { return }
        let original = splits[index]
        splits[index] = split
        do {
            try StorageManager.shared.write(.splits, splits)
            if current?.id == split.id { current = split }
        } catch {
            splits[index] = original
            throw error
        }
    }
    
    func deleteSplit(_ split: Split) throws {
        if split.isBuiltin() { return }
        guard let index = splits.firstIndex(where: { $0.id == split.id }) else { return }
        splits.remove(at: index)
        do {
            try StorageManager.shared.write(.splits, splits)
            if split.id == current?.id { current = nil }
        } catch {
            splits.insert(split, at: index)
            throw error
        }
    }
    
    func selectSplit(_ split: Split?) throws {
        let prev = self.current
        self.current = split
        meta.splitId = split?.id
        do {
            try StorageManager.shared.write(.splitMeta, meta)
        } catch {
            self.current = prev
            throw error
        }
    }
    
    func setDayIndex(_ newDay: Day) {
        guard let current, let day else { return }
        guard let index = current.days.firstIndex(of: day) else { return }
        guard let newIndex = current.days.firstIndex(of: newDay) else { return }
        meta.dayIndex = newIndex
        self.day = current.days[newIndex]
        do {
            try StorageManager.shared.write(.splitMeta, meta)
        } catch {
            meta.dayIndex = index
            self.day = current.days[index]
        }
    }
    
    func nextDay() throws {
        guard let current, let day else { return }
        guard let index = current.days.firstIndex(where: { $0.id == day.id }) else { return }
        let newIndex = index == current.days.count - 1 ? 0 : index + 1
        meta.dayIndex = newIndex
        self.day = current.days[newIndex]
        do {
            try StorageManager.shared.write(.splitMeta, meta)
        } catch {
            meta.dayIndex = index
            self.day = current.days[index]
            throw error
        }
    }
    
    func prevDay() throws {
        guard let current, let day else { return }
        guard let index = current.days.firstIndex(where: { $0.id == day.id }) else { return }
        let newIndex = index == 0 ? current.days.count - 1 : index - 1
        meta.dayIndex = newIndex
        self.day = current.days[newIndex]
        do {
            try StorageManager.shared.write(.splitMeta, meta)
        } catch {
            meta.dayIndex = index
            self.day = current.days[newIndex]
            throw error
        }
    }
}

@Observable
final class SplitMeta: Codable, Hashable {
    var splitId: String?
    var dayIndex: Int?
    
    init(splitId: String?, dayIndex: Int?) {
        self.splitId = splitId
        self.dayIndex = dayIndex
    }
}
