//
//  Dialog.swift
//  Vincera
//
//  Created by Matt Linder on 11/4/24.
//

import SwiftUI

struct Dialog: Identifiable, Equatable {
    let id = UUID().uuidString
    let text: String
    let role: ButtonRole?
    let action: () -> Void
    
    static func == (lhs: Dialog, rhs: Dialog) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DialogView: View {
    @EnvironmentObject private var router: Router
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if router.dialog != nil {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .onTapGesture { dismiss() }
                    .transition(.opacity)
                    .animation(.linear(duration: 0.2), value: router.dialog)
            }
            if let dialog = router.dialog {
                VStack(spacing: 8) {
                    Button(role: dialog.role) { dialog.action(); dismiss() } label: {
                        Text(dialog.text)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .foregroundStyle(dialog.role == .destructive ? .red : .accent)
                    }
                    .bordered
                    .foregroundStyle(dialog.role == .destructive ? .red : .accent)
                    Button(role: .cancel) { dismiss() } label: {
                        Text("Cancel")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .bordered
                }
                .padding(8)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom),
                        removal: .offset(y: 200))
                )
                .animation(.snappy, value: router.dialog)
            }
        }
    }
    
    func dismiss() {
        withAnimation { router.dialog = nil }
    }
}

extension View {
    var dialogDisplayer: some View {
        self.overlay { DialogView() }
    }
}
