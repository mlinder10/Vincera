//
//  YoutubeView.swift
//  LiftLogs
//
//  Created by Matt Linder on 5/4/24.
//

import SwiftUI
import WebKit

struct YouTubeView: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        let urlString = "https://www.youtube.com/embed/\(videoID)?autoplay=1&loop=1&playlist=\(videoID)"
        //    let urlString = "https://www.youtube.com/embed/\(videoID)"
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update view if needed
    }
}
