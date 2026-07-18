//
//  CreatePlanAssistedScreen.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI

struct AssistedSplitScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var step: SurveyStep = SurveyStep.allCases.first!
    @State private var direction: AssistedForm.Direction = .forward
    @State private var isGenerating = false
    @State private var survey = SurveyDataDraft()
    
    var body: some View {
        VStack {
            TypewriterText("Generate a Split", speed: 0.08)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal, PADDING_INLINE)
            AssistedForm.FormProgressView(step: step)
                .padding(.horizontal, PADDING_INLINE)
            
            Spacer()
            
            AssistedForm.CoreView(
                step: $step,
                direction: $direction,
                survey: $survey
            )
            .padding(.horizontal, PADDING_INLINE)
            
            Spacer()
            
            AssistedForm.ActionButton(
                step: $step,
                direction: $direction,
                survey: survey,
                isGenerating: isGenerating,
                onGenerate: handleGenerate
            )
            .padding(.horizontal, PADDING_INLINE)
        }
        .padding(.bottom)
    }
    
    private func handleGenerate() {
        defer { isGenerating = false }
        guard let survey = self.survey.toSurveyData() else { return } // should never fail
        let split = SplitBuilder.build(survey)
        
        Task {
            await MainActor.run {
                isGenerating = true
                guard let _ = try? store.split.create(split) else {
                    Router.shared.toast("Failed to generate split", type: .error)
                    return
                }
                try? store.selectSplit(split)
            }
            
            await MainActor.run {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // use this to simulate "generation" in UI
                    Router.shared.pop()
                    Router.shared.push(SplitEditorRoute(split: split))
                }
            }
        }
    }
}

// form components ================================================

private struct FormComponent<Content: View>: View {
    let title: String
    var subtitle: String?
    var onBack: (() -> Void)? = nil
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Card {
            VStack(alignment: .leading) {
                SectionTitle(title, subtitle: subtitle)
                
                content()
                if let onBack {
                    HStack {
                        Button(
                            "Back",
                            systemImage: "arrow.left",
                            action: onBack
                        )
                        .font(.subheadline)
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

enum AssistedForm {
    enum Direction {
        case forward, backward
    }
    
    struct FormProgressView: View {
        let step: SurveyStep
        private var progress: Double {
            Double(SurveyStep.allCases.firstIndex(of: step)!) /
            Double(SurveyStep.allCases.count - 1)
        }
        
        var body: some View {
            ProgressView(value: progress)
                .animation(.easeOut, value: step)
        }
    }
    
    struct CoreView: View {
        @Binding var step: SurveyStep
        @Binding var direction: Direction
        @Binding var survey: SurveyDataDraft
        
        var body: some View {
            Group {
                switch step {
                case .measurements:
                    MeasurementsStepView(
                        heightFeet: $survey.heightFeet,
                        heightInches: $survey.heightInches,
                        weightInLbs: $survey.weightInLbs,
                        age: $survey.age,
                    )
                case .gender: GenderStepView(gender: $survey.gender, onBack: handlePrev)
                case .activity: ActivityStepView(activity: $survey.activityLevel, onBack: handlePrev)
                case .goal: GoalStepView(goal: $survey.goal, onBack: handlePrev)
                case .days: DaysStepView(days: $survey.daysPerWeek, onBack: handlePrev)
                case .muscles: MusclesStepView(targetMuscles: $survey.targetMuscles, onBack: handlePrev)
                case .equipment: EquipmentStepView(equipment: $survey.availableEquipment, onBack: handlePrev)
                }
            }
            .transition(
                .asymmetric(
                    insertion: .move(edge: direction == .forward ? .trailing : .leading),
                    removal: .move(edge: direction == .forward ? .leading : .trailing)
                )
            )
        }
        
        private func handlePrev() {
            guard let prev = step.prev else { return }
            direction = .backward
            withAnimation { step = prev }
        }
    }
    
    struct ActionButton: View {
        @Binding var step: SurveyStep
        @Binding var direction: Direction
        let survey: SurveyDataDraft
        var isGenerating = false
        let onGenerate: () -> Void
        
        var body: some View {
            Group {
                if let next = step.next {
                    BrandButton("Next", systemImage: "arrow.right") {
                        direction = .forward
                        withAnimation { step = next }
                    }
                    .primary
                    .disabled(survey.isDisabled(for: step))
                } else {
                    BrandButton(
                        isGenerating ? "Generating..." : "Generate",
                        systemImage: "sparkles",
                        action: onGenerate
                    )
                    .primary
                    .disabled(survey.isDisabled(for: step) || isGenerating)
                }
            }
        }
    }
    
    private struct MeasurementsStepView: View {
        @Binding var heightFeet: Int?
        @Binding var heightInches: Int?
        @Binding var weightInLbs: Int?
        @Binding var age: Int?
        
        var body: some View {
            FormComponent(title: "Measurements") {
                VStack {
                    HStack {
                        UnboundNumberField("Height", num: $heightFeet)
                            .unit("Ft")
                        UnboundNumberField("Height", num: $heightInches)
                            .unit("In")
                    }
                    UnboundNumberField("Weight", num: $weightInLbs)
                        .unit("Lbs")
                    UnboundNumberField("Age", num: $age)
                }
                .textFieldStyle(.roundedBorder)
            }
        }
    }
    
    private struct GenderStepView: View {
        @Binding var gender: Gender?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Gender", onBack: onBack) {
                RadioSelect(
                    selection: $gender,
                    options: Gender.allCases
                )
            }
        }
    }
    
    private struct ActivityStepView: View {
        @Binding var activity: ActivityLevel?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Activity Level", onBack: onBack) {
                RadioSelect(
                    selection: $activity,
                    options: ActivityLevel.allCases
                )
            }
        }
    }
    
    private struct GoalStepView: View {
        @Binding var goal: TrainingGoal?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Goal", onBack: onBack) {
                RadioSelect(
                    selection: $goal,
                    options: TrainingGoal.allCases
                )
            }
        }
    }
    
    private struct DaysStepView: View {
        @Binding var days: Int?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Days / Week", onBack: onBack) {
                RadioSelectWithOptions(
                    selection: $days,
                    options: [
                        .init("One", value: 1),
                        .init("Two", value: 2),
                        .init("Three", value: 3),
                        .init("Four", value: 4),
                        .init("Five", value: 5),
                        .init("Six", value: 6),
                        .init("Seven", value: 7),
                    ]
                )
            }
        }
    }
    
    private struct MusclesStepView: View {
        @Binding var targetMuscles: [MuscleGroup]
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Focus", subtitle: "Optional, (Max 4)", onBack: onBack) {
                MultiselectGrid(
                    selected: $targetMuscles,
                    options: MuscleGroup.allCases,
                    max: 4
                )
            }
        }
    }
    
    private struct EquipmentStepView: View {
        @Binding var equipment: [EquipmentType]
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Available Equipment", onBack: onBack) {
                MultiselectGrid(
                    selected: $equipment,
                    options: EquipmentType.allCases,
                    showAllButton: true
                )
            }
        }
    }
}

#Preview {
    AssistedSplitScreen()
        .mockNavigation
}
