//
//  OnboardingFlow.swift
//  Vincera
//
//  Created by Matt Linder on 4/20/26.
//

import SwiftUI

private let ONBOARDING_KEY = "com.mattlinder.vincera.onboarding.complete"

func isOnboardingComplete() -> Bool {
    UserDefaults.standard.bool(forKey: ONBOARDING_KEY)
}

func completeOnboarding() {
    UserDefaults.standard.set(true, forKey: ONBOARDING_KEY)
}

private class OnboardingRouter: ObservableObject {
    static let shared = OnboardingRouter()
    
    private init() {}
    
    @Published var path = [AnyRoute]()
    
    func push(_ route: any Route) {
        path.append(AnyRoute(route))
    }
}

struct OnboardingFlow: View {
    @ObservedObject private var router = OnboardingRouter.shared
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack {
                Spacer()
                
                VStack(spacing: 16) {
                    Image("Logo")
                        .resizable()
                        .frame(width: 200, height: 200)
                    
                    TypewriterText("Welcome to Vincera", speed: 0.08)
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("To get started, enter some information about yourself to create a custom training split.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 12)
                }
                
                Spacer()
                
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        BrandButton("Get Started") {
                            router.push(OnboardingFormRoute())
                        }
                        .primary
                        
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lock.shield.fill")
                                .font(.caption)
                                .foregroundStyle(.tint)
                            
                            Text("Your data is stored locally and on your private iCloud. It is never sent to our servers.")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, PADDING_INLINE)
            .navigationDestination(for: AnyRoute.self) { $0.base.view() }
        }
    }
}

private struct OnboardingFormRoute: Route {
    var name: String { "OnboardingForm" }
    var stacks: [ProtectedStack] = []
    
    func view() -> AnyView {
        AnyView(OnboardingForm())
    }
}

private struct OnboardingForm: View {
    @EnvironmentObject private var store: DataStore
    @ObservedObject private var router = OnboardingRouter.shared
    @State private var step: AssistedForm.Step = .sex
    @State private var direction: AssistedForm.Direction = .forward
    @State private var info = AssistedForm.SplitInfoDraft()
    @State private var isGenerating = false
    
    var body: some View {
        VStack {
            Text("Create A Split")
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
        .padding(.top, PADDING_TOP)
    }
    
    @MainActor
    private func handleGenerate() {
        defer { isGenerating = false }
        guard let info = self.info.toInfo() else { return }
        let split = SplitBuilder.build(info)
        
        Task {
            isGenerating = true
            guard let _ = try? store.createSplit(split) else {
                Router.shared.toast("Failed to generate split", type: .error)
                return
            }
            try? store.selectSplit(split)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { // use this to simulate "generation" in UI
                router.push(SplitPreviewRoute(split: split))
                completeOnboarding()
            }
        }
    }
}

private struct SplitPreviewRoute: Route {
    var name: String { "SplitPreview" }
    var stacks: [ProtectedStack] = []
    let split: Writers.Split
    
    func view() -> AnyView {
        AnyView(SplitPreviewView(split: split))
    }
}

private struct SplitPreviewView: View {
    @State private var isShowingPrompt = false
    let split: Writers.Split
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header borrowing from your Carousel label style
                VStack(spacing: 12) {
                    Text("AI GENERATED SPLIT")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(2)
                        .foregroundStyle(.tint)
                    
                    Text(split.name)
                        .font(.system(.title, design: .rounded)).bold()
                        .multilineTextAlignment(.center)
                    
                    Text(split.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                
                VStack(spacing: 16) {
                    ForEach(split.days) { day in
                        DayPreviewCard(day: day)
                    }
                }
                
                BrandButton("Continue") {
                    isShowingPrompt = true
                }
                .primary
                .padding(.vertical, 20)
            }
            .padding(.horizontal, PADDING_INLINE)
        }
        .navigationBarBackButtonHidden()
        .fullScreenCover(isPresented: $isShowingPrompt) {
            LockedView(subtitle: "Join today to access your Vincera - Full Access split and exclusive training tools.")
        }
    }
}

private struct DayPreviewCard: View {
    let day: Writers.Day
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                // Header borrowing from your WorkoutCarouselItem
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fromHex(day.color).opacity(0.15))
                            .frame(width: 40, height: 40)
                        
                        Text(day.name.prefix(1))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundStyle(Color.fromHex(day.color))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.name)
                            .font(.headline)
                        Text(day.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if day.isRest {
                        Text("REST")
                            .font(.caption2).bold()
                            .tracking(1)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if !day.isRest {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(day.wrappers.prefix(6)) { wrapper in
                            if let exercise = wrapper.exercises.first,
                               let listItem = ExerciseList.shared.getExercise(exercise.listId) {
                                HStack(spacing: 6) {
                                    Text("\(exercise.sets.count)x")
                                        .font(.system(.caption, design: .monospaced))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                    
                                    Text(listItem.name)
                                        .font(.caption)
                                        .foregroundStyle(.primary.opacity(0.9))
                                }
                            }
                        }
                    }
                }
            }
            .padding(4)
        }
    }
}

#Preview {
    OnboardingFlow()
//    SplitPreviewView(split: VINCERA_SPLITS.first!)
        .mockNavigation
        .mockEnvironment
}
