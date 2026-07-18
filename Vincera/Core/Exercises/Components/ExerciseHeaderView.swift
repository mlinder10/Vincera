//
//  ExerciseHeaderView.swift
//  Vincera
//
//  Created by Matt Linder on 5/29/26.
//

import SwiftUI

private let FALLBACK_IMAGE = UIImage(named: "empty-exercise")!

struct ExerciseHeaderView: View {
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

private struct HeaderImages: View {
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
    
    private func fetchImages() async -> (UIImage, UIImage?) {
        let leftImg = await fetchImage(self.leftImgStr)
        let rightImg = await fetchImage(self.rightImgStr)
        if let leftImg, let rightImg { return (leftImg, rightImg) }
        return (FALLBACK_IMAGE, nil)
    }
}

private struct HeaderText: View {
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
