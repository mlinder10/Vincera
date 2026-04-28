//
//  FilterRow.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct MultiSelectRow<T: StringRepresentable & Identifiable & Equatable & Hashable>: View {
    let title: String
    @Binding var selected: [T]
    let options: [T]
    
    init(_ title: String, selected: Binding<[T]>, options: [T]) {
        self.title = title
        self._selected = selected
        self.options = options
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                if !selected.isEmpty {
                    Button {
                        withAnimation {
                            selected = []
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThickMaterial)
                    )
                    .transition(
                        .move(edge: .leading)
                    )
                }
                ForEach(selected) { option in
                    OptionCell(selected: $selected, option: option, options: options)
                }
                ForEach(options.filter { !selected.contains($0) }) { option in
                    OptionCell(selected: $selected, option: option, options: options)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct OptionCell<T: StringRepresentable & Identifiable & Hashable>: View {
    @Binding var selected: [T]
    let option: T
    let options: [T]
    
    var body: some View {
        Group {
            let isSelected = selected.contains(option)
            Button {
                withAnimation {
                    selected.toggle(option)
                }
            } label: {
                Text(option.string)
                    .selectable(isSelected)
            }
        }
    }
}
