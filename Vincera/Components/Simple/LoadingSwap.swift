//
//  LoadingSwap.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI

struct LoadingSwap<Content: View, T>: View {
    let item: T?
    let content: (T) -> Content
    
    init(isLoading: Bool, @ViewBuilder content: @escaping (T) -> Content) where T == Bool {
        self.item = isLoading ? nil : true
        self.content = content
    }
    
    init(_ item: T?, @ViewBuilder content: @escaping (T) -> Content) {
        self.item = item
        self.content = content
    }
    
    var body: some View {
        if let item {
            content(item)
        } else {
            ProgressView()
        }
    }
}
