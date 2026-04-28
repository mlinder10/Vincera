//
//  DetailView.swift
//  Vincera
//
//  Created by Matt Linder on 3/22/26.
//

import SwiftUI

struct DetailView<Content : View>: View {
    @State private var isPresented = false
    var icon: String? = nil
    var title: String
    var description: String
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Button { isPresented = true } label: {
            content()
        }
        .sheet(isPresented: $isPresented) {
            VStack(spacing: 16) {
                HStack {
                    Button("Dismiss", systemImage: "xmark") {
                        isPresented = false
                    }
                    Spacer()
                }
                
                HStack {
                    if let icon {
                        Image(systemName: icon)
                    }
                    Text(title)
                }
                .fontWeight(.semibold)
                .font(.title3)
                
                Text(description)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .presentationDetents([.medium])
        }
    }
}
