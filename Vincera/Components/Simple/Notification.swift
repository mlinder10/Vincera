//
//  NotificationView.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI

enum NotificationType {
    case danger
    case warning
    case success
    case message
    
    var foregroundStyle: Color {
        switch self {
        case .danger: .red
        case .warning: .yellow
        case .success: .green
        case .message: .primary
        }
    }
    
    var icon: String {
        switch self {
        case .danger: "exclamationmark.triangle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .success: "checkmark.circle.fill"
        case .message: "message.fill"
        }
    }
}

struct Notification: Identifiable, Equatable {
    let id = UUID().uuidString
    let message: String
    let type: NotificationType
    var offsetX: CGFloat = 0
    var isDeleting: Bool = false
    
    static func == (lhs: Notification, rhs: Notification) -> Bool {
        return lhs.id == rhs.id
    }
}

struct NotificationView: View {
    let notification: Notification
    let dismiss: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: notification.type.icon)
                .foregroundStyle(notification.type.foregroundStyle)
            Text(notification.message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
            }
            .foregroundStyle(notification.type.foregroundStyle)
        }
        .padding(.vertical, 12)
        .padding(.leading, 15)
        .padding(.trailing, 10)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.06), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 1, y: 3)
        )
        .padding(.horizontal, 15)
    }
}

struct NotificationDisplayer: ViewModifier {
    @EnvironmentObject private var router: Router
    
    func body(content: Content) -> some View {
        content.overlay {
            ZStack(alignment: .bottom) {
                if router.notification != nil {
                    Color.clear
                        .ignoresSafeArea()
                        .onTapGesture(perform: dismiss)
                }
                if let notification = router.notification {
                    NotificationView(notification: notification, dismiss: dismiss)
                        .offset(x: notification.offsetX)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .bottom),
                                removal: .move(edge: .leading)
                            )
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    router.notification?.offsetX = value.translation.width < 0 ? value.translation.width : 0
                                }.onEnded { value in
                                    let xOffset = value.translation.width + value.velocity.width / 2
                                    if -xOffset > 200 {
                                        dismiss()
                                    } else {
                                        router.notification?.offsetX = 0
                                    }
                                }
                        )
                }
            }
        }
    }
    
    func dismiss() {
        withAnimation { router.notification = nil }
    }
}

extension View {
    var notificationDisplayer: some View {
        modifier(NotificationDisplayer())
    }
}
