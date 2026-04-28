//
//  RatingModal.swift
//  Vincera
//
//  Created by Matt Linder on 4/26/26.
//

import SwiftUI

private let RATING_KEY = "com.mattlinder.vincera.has_rated"

func hasRated() -> Bool {
    if let date = UserDefaults.standard.object(forKey: RATING_KEY) as? Date {
        return Date().timeIntervalSince(date) < 60 * 60 * 24 * 31 * 4 // only ask 3x per year
    }
    return false
}

private func setHasRated() {
    UserDefaults.standard.set(Date(), forKey: RATING_KEY)
}

struct RatingModal: View {
    @Environment(\.requestReview) private var requestReview
    @State private var didTapNo = false
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.8)
                .ignoresSafeArea()
            
            Card {
                VStack(spacing: 20) {
                    if didTapNo {
                        apologyView
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        questionView
                            .transition(.opacity)
                    }
                }
                .padding(.vertical, 8)
                .animation(.easeInOut, value: didTapNo)
            }
            .padding(.horizontal, PADDING_INLINE)
        }
    }
    
    private var questionView: some View {
        VStack(spacing: 16) {
            Text("Enjoying Vincera?")
                .font(.headline)
            
            HStack(spacing: 12) {
                BrandButton("No") {
                    withAnimation {
                        didTapNo = true
                    }
                }
                .secondary // Assuming this provides a more muted look
                
                BrandButton("Yes!") {
                    requestReview()
                    handleDismiss()
                }
                .primary
            }
        }
    }
    
    private var apologyView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("We're sorry to hear that.")
                    .font(.headline)
                
                Text("Your feedback helps us improve. You can reach out directly via the Account page.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            BrandButton("Got it", action: handleDismiss)
                .secondary
        }
    }
    
    private func handleDismiss() {
        setHasRated()
        onDismiss()
    }
}

#Preview {
    VStack {
        RatingModal(onDismiss: {})
            .padding(.horizontal, PADDING_INLINE)
    }
}
