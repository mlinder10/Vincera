//
//  Haptics.swift
//  Weights
//
//  Created by Matt Linder on 8/26/24.
//

import Foundation
import SwiftUI

final class Haptics: Sendable {
    static let shared = Haptics()
    
    private init() {}
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.sync {
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
        }
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.sync {
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
    }
}
