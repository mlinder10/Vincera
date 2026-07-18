//
//  SplitBuilder.swift
//  Vincera
//
//  Created by Matt Linder on 4/22/26.
//

import Foundation

private struct Metadata {
    var sfrs: [String: WeeklyValues]
    
    init() {
        self.sfrs = [:]
        for group in MuscleGroup.allCases {
            self.sfrs[group.rawValue] = WeeklyValues()
        }
    }
    
    struct WeeklyValues {
        var sets: Int
        var stimulus: Int
        var fatigue: Double
        var cardioMinutes: Int
        
        init() {
            self.sets = 0
            self.stimulus = 0
            self.fatigue = 0.0
            self.cardioMinutes = 0
        }
        
        mutating func add(sets: Int, for exercise: ListExercise, adjustedFatigue: Double) {
            self.sets += sets
            self.stimulus += exercise.stimulus
            self.fatigue += adjustedFatigue
        }
    }
}

final class SplitBuilder {
    private var split: Builder.Split
    private var survey: SurveyData
    private var metadata: Metadata
    
    private init(_ survey: SurveyData) {
        self.split = Builder.Split.new()
        self.survey = survey
        self.metadata = Metadata()
    }
    
    static func build(_ survey: SurveyData) -> Writers.Split {
        return SplitBuilder(survey)
            .buildName()
            .buildDescription()
            .buildDays()
            .buildExercises() // Pass 1: Structural Foundation
            .buildVolume()    // Pass 2: Set/Rep Logic
            .buildCardio()
            .split
            .toWriter()
    }
    
    // MARK: - Structural Functions
    
    private func buildName() -> Self {
        switch survey.daysPerWeek {
        case 1: split.name = "Full Body"
        case 2: split.name = "Full Body"
        case 3: split.name = "Full Body / Upper Lower"
        case 4: split.name = "Upper / Lower"
        case 5: split.name = "Upper Lower / Push Pull Legs"
        case 6: split.name = "Push Pull Legs"
        case 7: split.name = "Push Pull Legs"
        default: break
        }
        
        split.name += " for "
        
        switch survey.goal {
        case .strength: split.name += "Strength"
        case .muscleGain: split.name += "Muscle Gain"
        case .fatLoss: split.name += "Fat Loss"
        }
        
        return self
    }
    
    private func buildDescription() -> Self {
        switch survey.daysPerWeek {
        case 1: split.description = "One"
        case 2: split.description = "Two"
        case 3: split.description = "Three"
        case 4: split.description = "Four"
        case 5: split.description = "Five"
        case 6: split.description = "Six"
        case 7: split.description = "Seven"
        default: break
        }
        
        split.description += " day split "
        if !survey.targetMuscles.isEmpty {
            split.description += "with a focus on "
            split.description += survey.targetMuscles.map({ $0.rawValue }).joined(separator: ", ")
        }
        
        split.description += " using "
        split.description += survey.availableEquipment.map({ $0.rawValue }).joined(separator: ", ")
        
        return self
    }
    
    private func buildDays() -> Self {
        let hasFocus = !survey.targetMuscles.isEmpty
        
        split.days = switch survey.daysPerWeek {
        case 1: [.init("Full Body", ""), .rest(), .rest(), .rest(), .rest(), .rest(), .rest()]
        case 2: [.init("Full Body A", ""), .rest(), .rest(), .init("Full Body B", ""), .rest(), .rest(), .rest()]
        case 3: [.init("Full Body", ""), .rest(), .rest(), .init("Upper", ""), .rest(), .init("Lower", ""), .rest()]
        case 4: [.init("Upper A", ""), .init("Lower A", ""), .rest(), .init("Upper B", ""), .rest(), .init("Lower B", ""), .rest()]
        case 5: [.init("Upper", ""), .init("Lower", ""), .rest(), .init("Push", ""), .init("Pull", ""), .init("Legs", ""), .rest()]
        case 6: [.init("Push", ""), .init("Pull", ""), .init("Legs", ""), .init("Push", ""), .init("Pull", ""), .init("Legs", ""), .rest()]
        case 7: [.init("Push", ""), .init("Pull", ""), .init("Legs", ""), .init("Push", ""), .init("Pull", ""), .init("Legs", ""), .init(hasFocus ? "Focused Muscle Groups" : "Full Body", "")]
        default: []
        }
        return self
    }
    
    // MARK: - Core Logic
    
    private func buildExercises() -> Self {
        for day in split.days {
            if day.isRest { continue }
            
            let targetGroups = muscleGroupsFromName(
                day.name,
                targetMuscles: survey.targetMuscles,
                gender: survey.gender
            )
            
            for group in targetGroups {
                // 1. Filter Pool
                let pool = ExerciseList.shared.exercises.values.filter { e in
                    e.primaryGroup == group.rawValue &&
                    survey.availableEquipment.map({ $0.rawValue }).contains(e.equipmentType)
                }
                
                // 2. Identify already selected exercises in the ENTIRE split for variety
                let globalSelectedIDs = split.days.flatMap { $0.wrappers.flatMap { $0.exercises.map { $0.listId } } }
                let currentDayIDs = day.wrappers.flatMap { $0.exercises.map { $0.listId } }
                
                // 3. Anchor Rule: If this is the first exercise of a major group, prioritize compounds
                let isAnchor = day.wrappers.isEmpty
                let weightedPool = pool.map { e -> (ListExercise, Double) in
                    var score = scoreExercise(
                        e,
                        globalSelected: globalSelectedIDs,
                        currentDaySelected: currentDayIDs,
                        goal: survey.goal
                    )
                    if isAnchor && e.exerciseType == ExerciseType.compound.rawValue { score += 10.0 }
                    return (e, score)
                }
                
                let sortedPool = weightedPool.sorted { $0.1 > $1.1 }
                
                // 4. Selection (Preventing name/pattern redundancy)
                if let bestChoice = sortedPool.first(where: { (e, _) in
                    !day.wrappers.contains(where: { wrapper in
                        guard let wrapperEx = ExerciseList.shared.getExercise(wrapper.exercises.first?.listId ?? "") else { return false }
                        // Prevent two variations of the same name (e.g. "Dumbbell Fly" and "Cable Fly") in one day
                        return e.name.contains(wrapperEx.name) || wrapperEx.name.contains(e.name)
                    })
                }) {
                    let exercise = bestChoice.0
                    day.wrappers.append(Builder.Wrapper.fromList(exercise, setCount: 2))
                    
                    // Track metadata for Focus Group logic
                    let adjFatigue = calculateAdjustedFatigue(exercise)
                    metadata.sfrs[exercise.primaryGroup]?.add(sets: 2, for: exercise, adjustedFatigue: adjFatigue)
                }
            }
            
            // Final Structural Sort
            day.wrappers.sort { w1, w2 in
                let e1 = ExerciseList.shared.getExercise(w1.exercises.first?.listId ?? "")
                let e2 = ExerciseList.shared.getExercise(w2.exercises.first?.listId ?? "")
                return (e1?.exerciseType == ExerciseType.compound.rawValue ? 0 : 1) <
                    (e2?.exerciseType == ExerciseType.compound.rawValue ? 0 : 1)
            }
        }
        return self
    }
    
    private func buildVolume() -> Self {
        for day in split.days {
            for wrapper in day.wrappers {
                let targetExercise = wrapper.exercises[0]
                guard let listExercise = ExerciseList.shared.getExercise(targetExercise.listId) else { continue }
                
                // 1. Set Count Logic (MRV Adjustment)
                // Focus groups get +1 set, Females get +1 set
                if survey.targetMuscles.map({ $0.rawValue }).contains(listExercise.primaryGroup) {
                    targetExercise.addSet()
                }
                if survey.gender == .female {
                    targetExercise.addSet()
                }
                
                // 2. Rep Count Logic
                for j in 0..<targetExercise.sets.count {
                    var reps = switch survey.goal {
                    case .strength: listExercise.repsLow
                    case .muscleGain: (listExercise.repsLow + listExercise.repsHigh) / 2
                    case .fatLoss: listExercise.repsHigh
                    }
                    
                    // Women handle higher relative volume/metabolic stress better
                    if survey.gender == .female {
                        reps += (survey.goal == .muscleGain ? 3 : 2)
                    }
                    
                    targetExercise.sets[j].valueTwo = Double(reps)
                }
            }
        }
        return self
    }
    
    private func buildCardio() -> Self {
        // Only apply if the goal is weight loss
        guard survey.goal == .fatLoss else { return self }
        
        for day in split.days {
            if day.isRest { continue }
            
            // 1. Determine cardio type based on the day's fatigue
            // If it was a heavy 'Lower' or 'Legs' day, pick low-impact cardio (LISS)
            // If it was 'Upper', we can suggest higher intensity (HIIT)
            let isLegDay = day.name.contains("Lower") || day.name.contains("Legs")
            
            let cardioPool = ExerciseList.shared.exercises.values.filter { e in
                e.exerciseType == ExerciseType.cardio.rawValue
            }
            
            if let chosenCardio = cardioPool.randomElement() {
                // Add as a final wrapper with a specific time instead of sets
                let duration = isLegDay ? 20 : 15 // Minutes
                let cardioWrapper = Builder.Wrapper.fromList(chosenCardio, setCount: 1)
                
                // Assuming your Wrapper/Set model can store "Minutes" in a field
                if chosenCardio.unitsOne == ExerciseUnit.time {
                    cardioWrapper.exercises[0].sets[0].valueOne = Double(duration)
                } else {
                    cardioWrapper.exercises[0].sets[0].valueTwo = Double(duration)
                }
                
                day.wrappers.append(cardioWrapper)
            }
        }
        return self
    }
    
    // MARK: - Internal Logic
    
    private func calculateAdjustedFatigue(_ e: ListExercise) -> Double {
        // Systemic Fatigue Tax: +0.5 per secondary muscle group involved
        let secondaryTax = Double(e.secondaryGroups.count) * 0.5
        return Double(e.fatigue) + secondaryTax
    }
    
    private func scoreExercise(_ e: ListExercise, globalSelected: [String], currentDaySelected: [String], goal: TrainingGoal) -> Double {
        let adjFatigue = calculateAdjustedFatigue(e)
        var score = Double(e.stimulus) / max(1.0, adjFatigue)
        
        // Penalize repeating exercises across the whole week (Variety)
        if globalSelected.contains(e.id) { score -= 5.0 }
        
        // Hard penalty for repeating in the same day (Safety)
        if currentDaySelected.contains(e.id) { score -= 20.0 }
        
        switch goal {
        case .strength:
            if e.exerciseType == ExerciseType.compound.rawValue { score += 5.0 }
            if e.equipmentType == EquipmentType.barbell.rawValue { score += 3.0 }
        case .muscleGain:
            // Size prioritizes total stimulus and machine stability
            score += Double(e.stimulus) * 0.4
            if e.equipmentType == EquipmentType.machine.rawValue || e.equipmentType == EquipmentType.cable.rawValue { score += 1.5 }
        case .fatLoss:
            // Favor exercises with lower fatigue to allow for shorter rest periods
            if e.fatigue <= 3 { score += 2.0 }
        }
        
        // Random variance to ensure unique splits on every "Generate" tap
        score += Double.random(in: 0...0.3)
        
        return score
    }
}

// MARK: - Helpers

private func muscleGroupsFromName(_ name: String, targetMuscles: [MuscleGroup], gender: Gender) -> [MuscleGroup] {
    // Physiological Bias: Female users get Glute priority in FB/Lower days
    let fbGroups: [MuscleGroup] = (gender == .female)
        ? [.glutes, .quads, .hams, .lats, .pecs, .sideDelts, .abs]
        : [.quads, .pecs, .hams, .lats, .tris, .bis, .sideDelts]
    
    let lowerGroups: [MuscleGroup] = (gender == .female)
        ? [.glutes, .glutes, .hams, .quads, .adductors, .gastrocnemius]
        : [.quads, .quads, .hams, .glutes, .adductors, .gastrocnemius]

    if name.contains("Full Body") { return fbGroups }
    if name.contains("Upper") { return [.pecs, .lats, .tris, .traps, .bis, .rearDelts, .abs] }
    if name.contains("Lower") { return lowerGroups }
    if name.contains("Push") { return [.pecs, .pecs, .frontDelts, .tris, .tris, .sideDelts] }
    if name.contains("Pull") { return [.lats, .lats, .traps, .bis, .bis, .rearDelts, .abs] }
    if name.contains("Legs") { return lowerGroups }
    
    if name.contains("Focused Muscle Groups") {
        if targetMuscles.count >= 3 { return targetMuscles.flatMap { [$0, $0] } }
        if targetMuscles.count == 2 { return targetMuscles.flatMap { [$0, $0, $0] } }
        if targetMuscles.count == 1 { return [targetMuscles[0], targetMuscles[0], targetMuscles[0], targetMuscles[0], targetMuscles[0]] }
    }
    
    return []
}
