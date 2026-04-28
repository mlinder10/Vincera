//
//  RadioSelect.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI

struct RadioSelect<
    T: RawRepresentable & Equatable & Hashable
>: View where T.RawValue == String {
    @Binding var selection: T?
    let options: [T]
    
    var body: some View {
        ForEach(options, id: \.self) { option in
            Card {
                HStack {
                    Image(systemName: option == selection ? "circle.fill" : "circle")
                        .foregroundStyle(.accent)
                    Text(option.rawValue)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { selection = option }
            }
        }
    }
}
