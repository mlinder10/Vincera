//
//  Haptics.swift
//  Weights
//
//  Created by Matt Linder on 8/26/24.
//

import Foundation
import SwiftUI

@MainActor
final class Haptics {
  static let shared = Haptics()
  
  private init() {}
  
  func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
    UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
  }
  
  func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
    UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
  }
}
