//
//  Badge.swift
//  Vincera
//
//  Created by Matt Linder on 5/31/26.
//

import SwiftUI

struct Badge: View {
    private let icon: String?
    private let title: String
    private let color: Color
    
    init(_ title: String, systemImage: String? = nil, color: Color = .secondary) {
        self.title = title
        self.icon = systemImage
        self.color = color
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
            }
            Text(title)
        }
        .foregroundStyle(color)
        .font(.system(.caption, design: .rounded))
        
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}
