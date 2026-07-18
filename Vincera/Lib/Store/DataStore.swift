//
//  DataStore.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import Foundation

final class DataStore: ObservableObject {
    // shared
    @Published var surveyData = DataStoreObject<SurveyData, SurveyData>(SurveyData(), file: File.survey)
    // workout
    @Published var split = DataStoreList<Writers.Split>(file: File.splitsV2)
    @Published var completedWorkout = DataStoreList<Writers.CompletedWorkout>(file: File.completedWorkoutsV2)
    @Published var tracker = DataStoreList<Writers.PRTracker>(file: File.trackers)
    
    @Published var activeWorkout = DataStoreObject<Builder.ActiveWorkout?, Writers.ActiveWorkout?>(
        nil,
        file: File.activeWorkout,
        decode: { $0?.toBuilder() },
        encode: { $0?.toWriter() }
    )
    @Published var workoutTimer = TimerData()
    @Published var splitMeta = DataStoreObject<Writers.SplitMeta, Writers.SplitMeta?>(
        Writers.SplitMeta(),
        file: File.splitMeta
    )
    
    var currentSplit: Writers.Split? {
        VINCERA_SPLITS.first(where: { $0.id == splitMeta.item.splitId }) ??
        split.list.first(where: { $0.id == splitMeta.item.splitId })
    }
    var currentDay: Writers.Day? {
        guard let currentSplit,
              let dayIndex = splitMeta.item.dayIndex,
              currentSplit.days.count > dayIndex else { return nil }
        return currentSplit.days[dayIndex]
    }
    
    init() {}
    
    func reload() {
        // shared
        self.surveyData.load(or: SurveyData())
        // workout
        self.split.load()
        self.completedWorkout.load()
        self.tracker.load()

        self.activeWorkout.load(or: nil)
        self.splitMeta.load(or: Writers.SplitMeta())
    }
    
    func initialize() -> Self {
        self.reload()
        return self
    }
    
    func mock() -> Self {
        self.surveyData.mock(MOCK_SURVEY_DATA)
        
        self.split.mock(MOCK_SPLITS)
        self.completedWorkout.mock(MOCK_COMPLETED_WORKOUTS)
        self.tracker.mock(MOCK_TRACKERS)

        self.splitMeta.mock(MOCK_SPLIT_META)
        return self
    }
}

// MARK: - List and Object types

final class DataStoreList<T: Codable & Equatable & Identifiable>: ObservableObject {
    @Published var list: [T] = []
    private let file: File
    
    init(file: File) {
        self.file = file
    }
    
    func load() {
        self.list = (try? StorageManager.read(file)) ?? []
    }
    
    func mock(_ data: [T]) {
        self.list = data
    }
    
    func `import`(_ other: [T]) throws {
        let nonExisting = other.filter({ o in !list.contains(where: { $0.id == o.id }) })
        if nonExisting.isEmpty { return }
        list.append(contentsOf: nonExisting)
        try StorageManager.write(file, list)
    }
    
    func clear() {
        list = []
        try? StorageManager.write(file, list)
    }
    
    func create(_ item: T) throws {
        list.insert(item, at: 0)
        do {
            try StorageManager.write(file, list)
        } catch {
            list.removeFirst()
            throw error
        }
    }
    
    func createMany(_ items: [T]) throws {
        list.insert(contentsOf: items, at: 0)
        do {
            try StorageManager.write(file, list)
        } catch {
            list.removeFirst(items.count)
            throw error
        }
    }
    
    func edit(_ item: T) throws {
        guard let index = list.firstIndex(where: { $0.id == item.id }) else { return }
        let original = list[index]
        list[index] = item
        do {
            try StorageManager.write(file, list)
        } catch {
            list[index] = original
            throw error
        }
    }
    
    func delete(_ item: T) throws {
        guard let index = list.firstIndex(of: item) else { return }
        list.remove(at: index)
        do {
            try StorageManager.write(file, list)
        } catch {
            list.insert(item, at: index)
            throw error
        }
    }
    
    func save() throws {
        try StorageManager.write(file, list)
    }
}

final class DataStoreObject<T, U: Codable>: ObservableObject {
    @Published var item: T
    private let file: File
    private let decode: (U) -> T
    private let encode: (T) -> U
    
    init(
        _ item: T,
        file: File,
        decode: @escaping (U) -> T = { item in
            guard let base = item as? T else { fatalError("Tried calling defaultDecode on a non-T") }
            return base
        },
        encode: @escaping (T) -> U = { item in
            guard let base = item as? U else { fatalError("Tried calling defaultEncode on a non-U") }
            return base
        }
    ) {
        self.item = item
        self.file = file
        self.decode = decode
        self.encode = encode
    }
    
    
    
    func load(or defaultValue: T) {
        if let item: U = try? StorageManager.read(file) {
            self.item = decode(item)
        } else {
            self.item = defaultValue
        }
    }
    
    func mock(_ item: T) {
        self.item = item
    }
    
    func update(_ item: T) throws {
        let original = self.item
        self.item = item
        do {
            try StorageManager.write(file, encode(self.item))
        } catch {
            self.item = original
            throw error
        }
    }
    
    func save() throws {
        try StorageManager.write(file, encode(item))
    }
}
