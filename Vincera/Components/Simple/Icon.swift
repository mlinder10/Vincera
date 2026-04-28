//
//  Icon.swift
//  Vincera
//
//  Created by Matt Linder on 4/18/26.
//

import SwiftUI

struct Icon: View {
    let systemName: String
    var color: Color = .primary
    var size: CGFloat = 24
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size))
            .foregroundStyle(color)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: size / 3)
                    .fill(.thinMaterial)
                    .stroke(.backgroundSecondary.opacity(0.8), style: StrokeStyle(lineWidth: 1))
                    .aspectRatio(1.0, contentMode: .fit)
            )
    }
}
