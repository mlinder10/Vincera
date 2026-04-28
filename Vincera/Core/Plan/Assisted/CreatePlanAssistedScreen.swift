//
//  CreatePlanAssistedScreen.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI
import StoreKit

enum AssistedForm {
    enum Step: CaseIterable, Equatable, Hashable {
        case sex, days, goal, focus, equipment
        
        var next: Step? {
            if self == Self.allCases.last { return nil }
            return Self.allCases[Self.allCases.firstIndex(of: self)! + 1]
        }
        
        var prev: Step? {
            if self == Self.allCases.first { return nil }
            return Self.allCases[Self.allCases.firstIndex(of: self)! - 1]
        }
    }
    
    enum Direction {
        case forward, backward
    }
    
    struct SplitInfoDraft {
        var sex: SplitInfo.Sex?
        var days: SplitInfo.Days?
        var goal: SplitInfo.Goal?
        var focus: [MuscleGroup] = []
        var equipment: [EquipmentType] = []
        
        func isDisabled(for step: Step) -> Bool {
            switch step {
            case .sex: sex == nil
            case .days: days == nil
            case .goal: goal == nil
            case .focus: false
            case .equipment: equipment.isEmpty
            }
        }
        
        func toInfo() -> SplitInfo? {
            guard let sex, let days, let goal else { return nil }
            return SplitInfo(
                sex: sex,
                days: days,
                goal: goal,
                focus: focus,
                equipment: equipment
            )
        }
    }
}

// main screen ================================================

struct AssistedSplitScreen: View {
    @EnvironmentObject private var store: DataStore
    @State private var step: AssistedForm.Step = .sex
    @State private var direction: AssistedForm.Direction = .forward
    @State private var isGenerating = false
    @State private var info = AssistedForm.SplitInfoDraft()
    
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
                info: $info
            )
            .padding(.horizontal, PADDING_INLINE)
            
            Spacer()
            
            AssistedForm.ActionButton(
                step: $step,
                direction: $direction,
                info: info,
                isGenerating: isGenerating,
                onGenerate: handleGenerate
            )
            .padding(.horizontal, PADDING_INLINE)
        }
        .padding(.bottom)
    }
    
    private func handleGenerate() {
        defer { isGenerating = false }
        guard let info = self.info.toInfo() else { return } // should never fail
        let split = SplitBuilder.build(info)
        
        Task {
            await MainActor.run {
                isGenerating = true
                guard let _ = try? store.createSplit(split) else {
                    Router.shared.toast("Failed to generate split", type: .error)
                    return
                }
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

extension AssistedForm { // components
    struct FormProgressView: View {
        let step: Step
        private var progress: Double {
            Double(Step.allCases.firstIndex(of: step)!) /
            Double(Step.allCases.count - 1)
        }
        
        var body: some View {
            ProgressView(value: progress)
                .animation(.easeOut, value: step)
        }
    }
    
    struct CoreView: View {
        @Binding var step: Step
        @Binding var direction: Direction
        @Binding var info: SplitInfoDraft
        
        var body: some View {
            Group {
                switch step {
                case .sex: AssistedForm.SexStepView(sex: $info.sex)
                case .days: AssistedForm.DaysStepView(days: $info.days, onBack: handlePrev)
                case .goal: AssistedForm.GoalStepView(goal: $info.goal, onBack: handlePrev)
                case .focus: AssistedForm.FocusStepView(focus: $info.focus, onBack: handlePrev)
                case .equipment: AssistedForm.EquipmentStepView(equipment: $info.equipment, onBack: handlePrev)
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
        @Binding var step: Step
        @Binding var direction: Direction
        let info: SplitInfoDraft
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
                    .disabled(info.isDisabled(for: step))
                } else {
                    BrandButton(
                        isGenerating ? "Generating..." : "Generate",
                        systemImage: "sparkles",
                        action: onGenerate
                    )
                    .primary
                    .disabled(info.isDisabled(for: step) || isGenerating)
                }
            }
        }
    }
    
    // sex
    private struct SexStepView: View {
        @Binding var sex: SplitInfo.Sex?
        
        var body: some View {
            FormComponent(title: "Sex") {
                RadioSelect(
                    selection: $sex,
                    options: SplitInfo.Sex.allCases
                )
            }
        }
    }
    
    // days / week
    private struct DaysStepView: View {
        @Binding var days: SplitInfo.Days?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Days / Week", onBack: onBack) {
                RadioSelect(
                    selection: $days,
                    options: SplitInfo.Days.allCases
                )
            }
        }
    }
    
    // goal
    private struct GoalStepView: View {
        @Binding var goal: SplitInfo.Goal?
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Goal", onBack: onBack) {
                RadioSelect(
                    selection: $goal,
                    options: SplitInfo.Goal.allCases
                )
            }
        }
    }
    
    // target muscles
    private struct FocusStepView: View {
        @Binding var focus: [MuscleGroup]
        let onBack: () -> Void
        
        var body: some View {
            FormComponent(title: "Focus", subtitle: "Optional, (Max 4)", onBack: onBack) {
                MultiselectGrid(
                    selected: $focus,
                    options: MuscleGroup.allCases,
                    max: 4
                )
            }
        }
    }
    
    // available equipment
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
