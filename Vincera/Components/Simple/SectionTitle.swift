//
//  SectionTitle.swift
//  Vincera
//
//  Created by Matt Linder on 3/24/26.
//

import SwiftUI

struct SectionTitle<Content: View>: View {
    private let title: String
    private let subtitle: String?
    var action: (() -> Content)
    
    init(_ title: String, subtitle: String? = nil, action: @escaping (() -> Content) = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if let subtitle {
                Text(subtitle)
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
            
            Spacer()
            action()
        }
        .padding(.horizontal)
    }
}
