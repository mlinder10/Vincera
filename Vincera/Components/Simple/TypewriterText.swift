//
//  TypewriterText.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI

private let SPEED = 0.2

struct TypewriterText: View {
    let text: String
    let speed: Double
    
    // Tracks how many characters total should be visible
    @State private var visibleCount = 0
    @State private var typingTask: Task<Void, Never>?
    
    init(_ text: String, speed: Double = SPEED) {
        self.text = text
        self.speed = speed
        self.visibleCount = visibleCount
        self.typingTask = typingTask
    }

    private var words: [String] {
        // Split by spaces but keep the spaces to preserve layout
        text.components(separatedBy: " ").map { $0 + " " }
    }

    var body: some View {
        FlowLayout(spacing: 0) {
            // We still iterate through words for the FlowLayout to wrap correctly
            ForEach(words, id: \.self) { word in
                HStack(spacing: 0) {
                    ForEach(Array(word.enumerated()), id: \.offset) { offset, char in
                        let charIndex = indexInFullText(word: word, charOffset: offset)
                        
                        if charIndex < visibleCount {
                            Text(String(char))
                                .transition(.move(edge: .top).combined(with: .opacity))
                        } else {
                            // Invisible placeholder to maintain width/kerning
                            Text(String(char)).opacity(0)
                        }
                    }
                }
            }
        }
        .onAppear { startTyping() }
    }

    // Helper to find the absolute index of a character across all words
    private func indexInFullText(word: String, charOffset: Int) -> Int {
        guard let wordIndex = words.firstIndex(of: word) else { return 0 }
        let previousChars = words.prefix(wordIndex).reduce(0) { $0 + $1.count }
        return previousChars + charOffset
    }

    private func startTyping() {
        typingTask?.cancel()
        visibleCount = 0
        typingTask = Task {
            for _ in text {
                if Task.isCancelled { break }
                try? await Task.sleep(nanoseconds: UInt64(speed * 1_000_000_000))
                await MainActor.run {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        visibleCount += 1
                    }
                }
            }
        }
    }
}

#Preview {
    TypewriterText("Hello!")
        .font(.largeTitle)
        .fontWeight(.bold)
}
