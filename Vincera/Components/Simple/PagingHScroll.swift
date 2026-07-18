//
//  PagingHScroll.swift
//  Vincera
//
//  Created by Matt Linder on 5/25/26.
//

import SwiftUI

private extension View {
    var scrolling: some View {
        self.containerRelativeFrame(.horizontal, count: 1, spacing: 24)
    }
    
    var scrollingRotate: some View {
        self.scrollTransition(axis: .horizontal) { content, phase in
            content
                .offset(y: phase.isIdentity ? 0 : 64)
                .scaleEffect(phase.isIdentity ? 1 : 0.8)
                .rotationEffect(.degrees(phase.value * 10))
        }
    }
}

struct PagingHScroll<T: View>: View {
    @ViewBuilder var content: T
    var withRotation = false
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 16) {
                content
                    .scrolling
                    .if(withRotation) { content in
                        content.scrollingRotate
                    }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .contentMargins(32)
        .scrollIndicators(.hidden)
    }
}
