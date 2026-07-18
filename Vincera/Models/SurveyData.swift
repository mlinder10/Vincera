//
//  SurveyData.swift
//  Vincera
//
//  Created by Matt Linder on 5/7/26.
//

enum SurveyStep: CaseIterable, Equatable, Hashable {
    case gender, goal, days, muscles, equipment
    
    var next: SurveyStep? {
        if self == Self.allCases.last { return nil }
        return Self.allCases[Self.allCases.firstIndex(of: self)! + 1]
    }
    
    var prev: SurveyStep? {
        if self == Self.allCases.first { return nil }
        return Self.allCases[Self.allCases.firstIndex(of: self)! - 1]
    }
}

struct SurveyDataDraft: Equatable, Hashable {
    var gender: Gender?
    var goal: TrainingGoal?
    var targetMuscles: [MuscleGroup]
    var availableEquipment: [EquipmentType]
    var daysPerWeek: Int?
    
    init(
        gender: Gender?,
        goal: TrainingGoal?,
        targetMuscles: [MuscleGroup],
        availableEquipment: [EquipmentType],
        daysPerWeek: Int?
    ) {
        self.gender = gender
        self.goal = goal
        self.targetMuscles = targetMuscles
        self.availableEquipment = availableEquipment
        self.daysPerWeek = daysPerWeek
    }
    
    init() {
        self.gender = nil
        self.goal = nil
        self.targetMuscles = []
        self.availableEquipment = []
        self.daysPerWeek = nil
    }
    
    func isDisabled(for step: SurveyStep) -> Bool {
        switch step {
        case .gender: gender == nil
        case .goal: goal == nil
        case .days: daysPerWeek == nil
        case .muscles: false
        case .equipment: availableEquipment.isEmpty
        }
    }
    
    func toSurveyData() -> SurveyData? {
        guard let gender, let goal, let daysPerWeek,
              !availableEquipment.isEmpty else { return nil }
        return SurveyData(
            gender: gender,
            goal: goal,
            targetMuscles: targetMuscles,
            availableEquipment: availableEquipment,
            daysPerWeek: daysPerWeek
        )
    }
}

struct SurveyData: Codable, Equatable {
    let gender: Gender
    let goal: TrainingGoal
    let targetMuscles: [MuscleGroup]
    let availableEquipment: [EquipmentType]
    let daysPerWeek: Int
    
    init(
        gender: Gender,
        goal: TrainingGoal,
        targetMuscles: [MuscleGroup],
        availableEquipment: [EquipmentType],
        daysPerWeek: Int
    ) {
        self.gender = gender
        self.goal = goal
        self.targetMuscles = targetMuscles
        self.availableEquipment = availableEquipment
        self.daysPerWeek = daysPerWeek
    }
    
    init() {
        self.gender = .male
        self.goal = .strength
        self.targetMuscles = []
        self.availableEquipment = []
        self.daysPerWeek = 0
    }
    
    func isValid() -> Bool {
        self != SurveyData()
    }
}

enum Gender: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    case male = "Male"
    case female = "Female"
}

enum TrainingGoal: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    case strength = "Strength"
    case muscleGain = "Muscle Gain"
    case fatLoss = "Fat Loss"
}
