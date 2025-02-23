//
//  LabeledDivider.swift
//  Weights
//
//  Created by Matt Linder on 8/12/24.
//

import SwiftUI

struct LabeledDivider: View {
    let label: String
    
    var body: some View {
        HStack {
            Rectangle().fill(.secondary).frame(maxWidth: .infinity).frame(height: 1)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Rectangle().fill(.secondary).frame(maxWidth: .infinity).frame(height: 1)
        }
    }
}

