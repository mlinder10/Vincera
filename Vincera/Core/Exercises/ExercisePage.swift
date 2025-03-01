//
//  ExerciseView.swift
//  LiftLogs
//
//  Created by Matt Linder on 4/17/24.
//

import SwiftUI
import Charts

private let FALLBACK_IMAGE = UIImage(named: "empty-exercise")!

struct ExercisePage: View {
    @Environment(\.dismiss) var dismiss
    @State private var showHeader = false
    @State private var width: CGFloat = 400
    let exercise: ListExercise
    private var isCustom: Bool { exercise.id.count == UUID_SIZE }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    ExerciseHeaderCell(
                        name: exercise.name,
                        leftImg: exercise.image + "-contracted",
                        rightImg: exercise.image + "-extended",
                        videoId: exercise.videoId
                    )
                    .readingFrame { frame in
                        showHeader = frame.maxY < 200
                        width = frame.maxX
                    }
                    if !isCustom {
                        ExerciseDetailsView(
                            description: exercise.description,
                            directions: exercise.directions,
                            cues: exercise.cues
                        )
                    }
                    if isCustom { DeleteButtonView(exercise: exercise) }
                }
                .padding(.bottom, 96)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
//            NavigationBarView(name: exercise.name, showHeader: showHeader)
        }
//        .toolbar(.hidden)
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
    @EnvironmentObject private var router: Router
    @EnvironmentObject private var eStore: ExerciseStore
    let exercise: ListExercise
    @State private var showingAlert = false
    
    var body: some View {
        Button(role: .destructive) { showingAlert = true } label: {
            Text("Delete Exercise")
                .frame(maxWidth: .infinity)
        }
        .borderedProminent
        .padding()
        .alert("Confirm Delete \(exercise.name)", isPresented: $showingAlert) {
            Button(role: .destructive) { handleDelete() } label: {
                Text("Delete")
            }
        }
    }
    
    func handleDelete() {
        do {
            try eStore.deleteExercise(exercise)
        } catch {
            router.notify(.danger, "Error deleting \(exercise.name)")
        }
    }
}

// NAVIGATION =============

fileprivate struct NavigationBarView: View {
    @Environment(\.dismiss) var dismiss
    let name: String
    let showHeader: Bool
    
    var body: some View {
        ZStack {
            Text(name)
                .font(.headline)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .opacity(showHeader ? 1 : 0)
                .offset(y: showHeader ? 0 : -40)
            
            Image(systemName: "chevron.left")
                .font(.title3)
                .padding(10)
                .background(showHeader ? Color.backgroundSecondary.opacity(0) : Color.backgroundSecondary.opacity(0.7))
                .clipShape(Circle())
                .onTapGesture { dismiss() }
                .padding(.leading, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .animation(.smooth(duration: 0.2), value: showHeader)
    }
}

fileprivate struct ExerciseHeaderCell: View {
    let name: String
    let height: CGFloat = 300
    let leftImg: String?
    let rightImg: String?
    let videoId: String?
    
    var body: some View {
        Rectangle()
            .opacity(1)
            .overlay(HeaderImages(leftImgStr: leftImg, rightImgStr: rightImg))
            .overlay(HeaderText(name: name, videoId: videoId), alignment: .bottomLeading)
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
    let videoId: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
            if let videoId, !videoId.isEmpty {
                NavigationLink {
                    YouTubeView(videoID: videoId)
                } label: {
                    HStack {
                        Text("Video Demonstration")
                    }
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
