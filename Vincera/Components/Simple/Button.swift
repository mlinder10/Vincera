//
//  Button.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI

struct BrandButton: View {
    let titleKey: String
    let systemImage: String?
    let role: ButtonRole?
    let isFullWidth: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(
        _ titleKey: String,
        systemImage: String? = nil,
        role: ButtonRole? = nil,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.role = role
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(role: role, action: action, label: {
            LoadingSwap(isLoading: isLoading) { _ in
                if let systemImage {
                    Label(titleKey, systemImage: systemImage)
                } else {
                    Text(titleKey)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
        })
    }
    
    func withAlert(title: String) -> some View {
        AlertButton(
            titleKey: titleKey,
            systemImage: systemImage,
            role: role,
            isFullWidth: isFullWidth,
            alertTitle: title,
            action: action
        )
    }
}

private struct AlertButton: View {
    @State private var showAlert = false
    let titleKey: String
    let systemImage: String?
    let role: ButtonRole?
    let isFullWidth: Bool
    let alertTitle: String
    let action: () -> Void
    
    var body: some View {
        BrandButton(
            titleKey,
            systemImage: systemImage,
            role: role,
            isFullWidth: isFullWidth,
            action: { showAlert = true }
        )
        .alert(alertTitle, isPresented: $showAlert) {
            if role != .destructive {
                HStack {
                    Button("Cancel", role: .cancel, action: { showAlert = false })
                    Button("Confirm", role: .confirm, action: action)
                }
            } else {
                Button("Confirm", role: role, action: action)
            }
        }
    }
}

struct NavigationButton<Content: View>: View {
    let titleKey: String
    let systemImage: String?
    let isFullWidth: Bool
    let isLoading: Bool
    let content: () -> Content
    
    init(
        _ titleKey: String,
        systemImage: String? = nil,
        isFullWidth: Bool = true,
        isLoading: Bool = false,
        content: @escaping () -> Content
    ) {
        self.titleKey = titleKey
        self.systemImage = systemImage
        self.isFullWidth = isFullWidth
        self.isLoading = isLoading
        self.content = content
    }
    
    var body: some View {
        NavigationLink {
            content()
        } label: {
            LoadingSwap(isLoading: isLoading) { _ in
                if let systemImage {
                    Label(titleKey, systemImage: systemImage)
                } else {
                    Text(titleKey)
                }
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
        }
    }
}

extension View {
    var primary: some View {
        self.modifier(PrimaryButtonStyle())
    }
    
    var secondary: some View {
        self.modifier(SecondaryButtonStyle())
    }
    
    var outline: some View {
        self.modifier(OutlineButtonStyle())
    }
}

private struct PrimaryButtonStyle: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .buttonStyle(.borderedProminent)
            .fontWeight(.semibold)
//            .buttonStyle(.borderedProminent)
//            .foregroundStyle(isEnabled ? Color.background : Color.primary.opacity(0.5))
//            .tint(isEnabled ? .accent : .gray.opacity(0.5))
    }
}

private struct SecondaryButtonStyle: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .buttonStyle(.bordered)
//            .foregroundStyle(isEnabled ? .accent : .gray)
    }
}

private struct OutlineButtonStyle: ViewModifier {
    @Environment(\.isEnabled) var isEnabled
    
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .padding(.vertical, 6)
            .background(
                Capsule().stroke(.accent, lineWidth: 1.5)
            )
    }
}
