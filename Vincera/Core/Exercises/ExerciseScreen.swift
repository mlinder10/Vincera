//
//  ExerciseScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 4/17/24.
//

import SwiftUI
import Charts

private let FALLBACK_IMAGE = UIImage(named: "empty-exercise")!

struct ExerciseScreen: View {
    @Environment(\.dismiss) private var dismiss
    let exercise: ListExercise
    
    var body: some View {
        ScrollView {
            VStack {
                ExerciseHeaderCell(
                    name: exercise.name,
                    leftImg: exercise.image + "-contracted",
                    rightImg: exercise.image + "-extended",
                    videoUrl: exercise.videoUrl
                )
                if !exercise.isCustom {
                    ExerciseDetailsView(
                        description: exercise.description,
                        directions: exercise.directions,
                        cues: exercise.cues
                    )
                }
                if exercise.isCustom { DeleteButtonView(exercise: exercise) }
            }
            .padding(.bottom, 96)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        .hiddenNavigation
    }
}

fileprivate struct ExerciseDetailsView: View {
    let description: String?
    let directions: [String]?
    let cues: [String]?
    
    var body: some View {
        VStack {
            if let description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let directions {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Directions")
                                .fontWeight(.semibold)
                                .padding(.vertical, 6)
                            ForEach(0..<directions.count, id: \.self) { index in
                                Text("\(index + 1). \(directions[index])")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        if let cues {
                            Text("Cues")
                                .fontWeight(.semibold)
                                .padding(.vertical, 6)
                            ForEach(cues, id: \.self) { cue in
                                Text("• \(cue)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
    }
}

fileprivate struct DeleteButtonView: View {
    let exercise: ListExercise
    
    var body: some View {
        BrandButton("Delete Exercise", role: .destructive, action: handleDelete)
            .withAlert(title: "Confirm Delete")
            .primary
            .padding()
    }
    
    func handleDelete() {
        do {
            try ExerciseList.shared.deleteExercise(exercise)
        } catch {
            Router.shared.toast("Error deleting \(exercise.name)", type: .error)
        }
    }
}

// HEADER =============

fileprivate struct ExerciseHeaderCell: View {
    let name: String
    let height: CGFloat = 300
    let leftImg: String?
    let rightImg: String?
    let videoUrl: String?
    
    var body: some View {
        Rectangle()
            .opacity(1)
            .overlay(HeaderImages(leftImgStr: leftImg, rightImgStr: rightImg))
            .overlay(HeaderText(name: name, videoUrl: videoUrl), alignment: .bottomLeading)
            .asStretchyHeader(startingHeight: height)
    }
}

fileprivate struct HeaderImages: View {
    @State private var leftImg = FALLBACK_IMAGE
    @State private var rightImg: UIImage? = nil
    let leftImgStr: String?
    let rightImgStr: String?
    
    var body: some View {
        HStack(spacing: 0) {
            if let rightImg {
                Image(uiImage: leftImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                Image(uiImage: rightImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(uiImage: leftImg)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .task { (self.leftImg, self.rightImg) = await fetchImages() }
    }
    
    func fetchImages() async -> (UIImage, UIImage?) {
        let leftImg = await fetchImage(self.leftImgStr)
        let rightImg = await fetchImage(self.rightImgStr)
        if let leftImg, let rightImg { return (leftImg, rightImg) }
        return (FALLBACK_IMAGE, nil)
    }
}

fileprivate struct HeaderText: View {
    let name: String
    let videoUrl: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            if let videoUrl, !videoUrl.isEmpty {
                NavigationLink("Video Demonstration") {
                    YouTubeShortView(videoUrl: videoUrl)
                }
            } else {
                Text("Video Unavailable")
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(32)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0)], startPoint: .bottom, endPoint: .top)
        )
    }
}

#Preview {
    NavigationStack {
        NavigationLink {
            ExerciseScreen(
                exercise: ListExercise(
                    id: UUID().uuidString,
                    name: "Bench Press",
                    description: "",
                    directions: [],
                    cues: [],
                    image: "bench-press",
                    videoUrl: "",
                    bodyPart: "Chest",
                    primaryGroup: "pectorals",
                    secondaryGroups: ["triceps", "front delts"],
                    exerciseType: "compound",
                    equipmentType: "barbell",
                    unitsOne: .weight,
                    unitsTwo: .reps,
                    repsLow: 2,
                    repsHigh: 8,
                    stimulus: 1,
                    fatigue: 1,
                )
            )
        } label: { Text("test") }
    }
}
