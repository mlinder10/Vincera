//
//  Card.swift
//  Vincera
//
//  Created by Matt Linder on 3/24/26.
//

import SwiftUI

enum CardShape {
    case rrect
    case rect
    case circle
    case capsule
    
    var view: AnyShape {
        switch self {
        case .rrect: AnyShape(RoundedRectangle(cornerRadius: 16))
        case .rect: AnyShape(Rectangle())
        case .circle: AnyShape(Circle())
        case .capsule: AnyShape(Capsule())
        }
    }
}

struct Card<Content: View>: View {
    let shape: CardShape
    let padding: CGFloat
    @ViewBuilder var content: () -> Content
    
    init(_ shape: CardShape = .rrect, padding: CGFloat = 16, @ViewBuilder content: @escaping () -> Content) {
        self.shape = shape
        self.padding = padding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .background(
                shape.view
                    .fill(.thinMaterial)
                    .stroke(.backgroundSecondary.opacity(0.8), style: StrokeStyle(lineWidth: 1))
            )
    }
}
