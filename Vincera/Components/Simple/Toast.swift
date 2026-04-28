//
//  Toast.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI

enum ToastType: Equatable {
    case error, warning, info, success
}

struct ToastData: Equatable {
    let type: ToastType
    let title: String
    var subtitle: String?
    
    var foregroundStyle: Color {
        switch self.type {
        case .error: .red
        case .warning: .yellow
        case .info: .primary
        case .success: .green
        }
    }
    
    var systemImage: String {
        switch self.type {
        case .error: "exclamationmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        }
    }
}

private let TOAST_LIFESPAN: CGFloat = 3 // seconds

struct ToastView: View {
    let data: ToastData
    
    var body: some View {
        Card(.capsule) {
            HStack(spacing: 8) {
                Image(systemName: data.systemImage)
                    .foregroundStyle(data.foregroundStyle)
                VStack(alignment: .leading) {
                    Text(data.title)
                    if let subtitle = data.subtitle {
                        Text(subtitle).font(.caption)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        
        .task {
            DispatchQueue.main.asyncAfter(deadline: .now() + TOAST_LIFESPAN) {
                Router.shared.toast = nil
            }
        }
    }
    
    private func dismiss() {
        withAnimation {
            Router.shared.toast = nil
        }
    }
}

extension View {
    func toastDisplay(router: Router) -> some View {
        ZStack(alignment: .bottom) {
            self
            
            if let toast = router.toast {
                ToastView(data: toast)
                    .padding(.bottom, 24)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(1)
            }
        }
        .animation(.snappy, value: router.toast)
    }
}

#Preview {
    @Previewable @StateObject var router = Router.shared
    VStack {
        BrandButton("test") {
            Router.shared.toast("Test", type: .success)
        }
        .primary
    }
    .frame(maxHeight: .infinity, alignment: .center)
    .toastDisplay(router: router)
}
