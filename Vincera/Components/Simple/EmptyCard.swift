//
//  EmptyCard.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

struct EmptyCard: View {
    let title: String
    let description: String
    var height: CGFloat? = 100
    
    var body: some View {
        Card {
            VStack {
                Text(title)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
        }
    }
}
