//
//  UIFunctions.swift
//  Vincera
//
//  Created by Matt Linder on 3/26/26.
//

import SwiftUI
import UniformTypeIdentifiers

final class Keyboard {
    static func dismiss() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

final class Clipboard {
    static func copy(_ text: String) {
        UIPasteboard.general.setValue(text, forPasteboardType: UTType.plainText.identifier)
    }
}

final class Haptics {
    static func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
        }
    }
    
    static func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
        }
    }
}
