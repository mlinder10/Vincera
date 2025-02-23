//
//  RRect.swift
//  Vincera
//
//  Created by Matt Linder on 11/29/24.
//

import SwiftUI

struct RRect<T: ShapeStyle>: View {
    let radius: CGFloat
    let fill: T
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius).fill(fill)
    }
}

extension View {
    nonisolated func backgroundRect<T: ShapeStyle>(radius: CGFloat, fill: T) -> some View {
        self.background(RRect(radius: radius, fill: fill))
    }
}
