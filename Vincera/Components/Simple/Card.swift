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

let CARD_COLOR = Color.backgroundSecondary.opacity(0.8)
private let DEFAULT_PADDING: CGFloat = 16

struct Card<Content: View>: View {
    let shape: CardShape
    let vPadding: CGFloat
    let hPadding: CGFloat
    @ViewBuilder var content: () -> Content
    
    init(
        _ shape: CardShape = .rrect,
        padding: CGFloat = DEFAULT_PADDING,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.shape = shape
        self.vPadding = padding
        self.hPadding = padding
        self.content = content
    }
    
    init(
        _ shape: CardShape = .rrect,
        vPadding: CGFloat = DEFAULT_PADDING,
        hPadding: CGFloat = DEFAULT_PADDING,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.shape = shape
        self.vPadding = vPadding
        self.hPadding = hPadding
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(.vertical, vPadding)
            .padding(.horizontal, hPadding)
            .background(
                shape.view
                    .fill(.thinMaterial)
                    .stroke(CARD_COLOR, style: StrokeStyle(lineWidth: 1))
            )
    }
}
