//
//  ExerciseList.swift
//  Vincera
//
//  Created by Matt Linder on 3/26/26.
//

import Foundation

let BASE_URL = "https://vinceratraining.com"
private let EXERCISES_ENDPOINT = "/exercises/v1.json"

final class ExerciseList: ObservableObject {
    static let shared = ExerciseList()
    
    @Published var exercises = [String: ListExercise]()
    private let client = HttpClient(baseUrl: BASE_URL)
    
    // init
    private init() {
        self.reload()
    }
    
    private func reload() {
        self.exercises = loadLocalExercises()
        let custom: [String: ListExercise] = (try? StorageManager.read(.exercisesMut)) ?? [:]
        exercises.merge(custom) { orig, _ in orig }
        
        Task {
            if let exercises = try? await self.fetchRemoteExercises() {
                // will load next time users open the app
                try? StorageManager.write(.exercisesRemote, exercises)
            }
        }
    }
    
    private func loadLocalExercises() -> [String: ListExercise] {
        var exercises: [String: ListExercise] = (try? StorageManager.read(.exercisesRemote)) ?? [:]
        if exercises.isEmpty { exercises = (try? StorageManager.read(.exercisesBase)) ?? [:] }
        return exercises
    }
    
    private func fetchRemoteExercises() async throws -> [String: ListExercise] {
        let (data, _) = try await client.request(EXERCISES_ENDPOINT)
        let decoded = try JSONDecoder().decode([String: RemoteListExercise].self, from: data)
        
        var result = [String: ListExercise]()
        for d in decoded {
            if let exercise = d.value.toListExercise() {
                result[d.key] = exercise
            }
        }
        
        return result
    }
    
    // crud
    
    func createExercise(_ exercise: ListExercise) throws {
        exercises[exercise.id] = exercise
        do {
            try StorageManager.write(.exercisesMut, getCustom())
        } catch {
            exercises.removeValue(forKey: exercise.id)
            throw error
        }
    }

    func editExercise(_ exercise: ListExercise) throws {
        guard exercise.isCustom else { return }
        let original = exercises[exercise.id]
        exercises[exercise.id] = exercise
        do {
            try StorageManager.write(.exercisesMut, getCustom())
        } catch {
            exercises[exercise.id] = original
            throw error
        }
    }

    func deleteExercise(_ exercise: ListExercise) throws {
        guard exercise.isCustom else { return }
        exercises.removeValue(forKey: exercise.id)
        do {
            try StorageManager.write(.exercisesMut, getCustom())
        } catch {
            exercises[exercise.id] = exercise
            throw error
        }
    }
    
    // helpers
    
    func `import`(_ exercises: [String: ListExercise]) {
        for (key, value) in exercises {
            if self.exercises[key] == nil {
                self.exercises[key] = value
            }
        }
        try? StorageManager.write(.exercisesMut, getCustom())
    }
    
    func clear() {
        try? StorageManager.write(.exercisesMut, [ListExercise]())
        self.reload()
    }
    
    private func getCustom() -> [String: ListExercise] { exercises.filter({ $0.value.isCustom }) }
    
    func getExercise(_ id: String) -> ListExercise? { exercises[id] }

    func getFiltered(_ filter: Filter) -> [String: ListExercise] {
        return exercises.filter { ex in
            (filter.search.isEmpty || ex.value.name.lowercased().contains(filter.search.lowercased())) &&
            (filter.exerciseTypes.isEmpty || filter.exerciseTypes.contains(where: { $0.rawValue == ex.value.exerciseType })) &&
            (filter.equipmentTypes.isEmpty || filter.equipmentTypes.contains(where: { $0.rawValue == ex.value.equipmentType })) &&
            (filter.bodyParts.isEmpty || filter.bodyParts.contains(where: { $0.rawValue == ex.value.bodyPart })) &&
            (filter.hidden.isEmpty || !filter.hidden.contains(ex.key))
        }
    }

    struct Filter: Equatable {
        var search = ""
        var exerciseTypes = [ExerciseType]()
        var equipmentTypes = [EquipmentType]()
        var bodyParts = [BodyPart]()
        var hidden = [String]()
    }
}
