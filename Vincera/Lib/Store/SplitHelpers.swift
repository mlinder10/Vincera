//
//  SplitHelpers.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

private let file = File.splitsV2

extension DataStore {
    
    // init
    
    func initSplits() {
        self.splits = (try? StorageManager.shared.read(file)) ?? []
        self.splitMeta = (try? StorageManager.shared.read(.splitMeta)) ?? Writers.SplitMeta(splitId: nil, dayIndex: nil)
    }
    
    // CRUD
    
    func createSplit(_ split: Writers.Split) throws {
        splits.insert(split, at: 0)
        do {
            try StorageManager.shared.write(file, splits)
            if currentSplit == nil {
                try? selectSplit(split)
            }
        } catch {
            splits.removeFirst()
            throw error
        }
    }
    
    func editSplit(_ split: Writers.Split) throws {
        if isSplitImmutable(splitId: split.id) {
            try createSplit(split.clone())
            return
        }
        guard let index = splits.firstIndex(where: { $0.id == split.id }) else { return }
        let original = splits[index]
        splits[index] = split
        do {
            try StorageManager.shared.write(file, splits)
        } catch {
            splits[index] = original
            throw error
        }
    }
    
    func deleteSplit(_ split: Writers.Split) throws {
        if isSplitImmutable(splitId: split.id) { return }
        guard let index = splits.firstIndex(where: { $0.id == split.id }) else { return }
        splits.remove(at: index)
        do {
            try StorageManager.shared.write(file, splits)
        } catch {
            splits.insert(split, at: index)
            throw error
        }
    }
    
    // helpers
    
    func selectSplit(_ split: Writers.Split?) throws {
        let original = Writers.SplitMeta(
            splitId: splitMeta.splitId,
            dayIndex: splitMeta.dayIndex
        )
        
        splitMeta.splitId = split?.id
        splitMeta.dayIndex = 0
        do {
            try StorageManager.shared.write(.splitMeta, splitMeta)
        } catch {
            splitMeta = original
            throw error
        }
    }
    
    func setDayIndex(_ newDay: Writers.Day) {
        guard let currentSplit, let currentDay else { return }
        guard let index = currentSplit.days.firstIndex(of: currentDay) else { return }
        guard let newIndex = currentSplit.days.firstIndex(of: newDay) else { return }
        splitMeta.dayIndex = newIndex
        do {
            try StorageManager.shared.write(.splitMeta, splitMeta)
        } catch {
            splitMeta.dayIndex = index
        }
    }
    
    func nextDay() throws {
        guard let currentSplit, let currentDay else { return }
        guard let index = currentSplit.days.firstIndex(where: { $0.id == currentDay.id }) else { return }
        let newIndex = index == currentSplit.days.count - 1 ? 0 : index + 1
        splitMeta.dayIndex = newIndex
        do {
            try StorageManager.shared.write(.splitMeta, splitMeta)
        } catch {
            splitMeta.dayIndex = index
            throw error
        }
    }
    
    func prevDay() throws {
        guard let currentSplit, let currentDay else { return }
        guard let index = currentSplit.days.firstIndex(where: { $0.id == currentDay.id }) else { return }
        let newIndex = index == 0 ? currentSplit.days.count - 1 : index - 1
        splitMeta.dayIndex = newIndex
        do {
            try StorageManager.shared.write(.splitMeta, splitMeta)
        } catch {
            splitMeta.dayIndex = index
            throw error
        }
    }
}
