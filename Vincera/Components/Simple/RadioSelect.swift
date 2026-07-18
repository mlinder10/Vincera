//
//  RadioSelect.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI

struct RadioOption<T: Hashable>: RawRepresentable, Equatable, Hashable {
    init?(rawValue: String) { nil }
    
    init(_ label: String, value: T) {
        self.label = label
        self.value = value
    }
    
    var rawValue: String { label }
    
    typealias RawValue = String
    
    let value: T
    let label: String
}

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

struct RadioSelectWithOptions<T: Hashable>: View {
    @Binding var selection: T?
    let options: [RadioOption<T>]
    
    var body: some View {
        ForEach(options, id: \.self) { option in
            Card {
                HStack {
                    Image(systemName: option.value == selection ? "circle.fill" : "circle")
                        .foregroundStyle(.accent)
                    Text(option.label)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { selection = option.value }
            }
        }
    }
}

struct MultiRadioSelect<
    T: RawRepresentable & Equatable & Hashable
>: View where T.RawValue == String {
    @Binding var selection: [T]
    let options: [T]
    
    var body: some View {
        ForEach(options, id: \.self) { option in
            Card {
                HStack {
                    Image(systemName: selection.contains(option) ? "circle.fill" : "circle")
                        .foregroundStyle(.accent)
                    Text(option.rawValue)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { toggle(option) }
            }
        }
    }
    
    private func toggle(_ option: T) {
        if let idx = selection.firstIndex(of: option) {
            selection.remove(at: idx)
        } else {
            selection.append(option)
        }
    }
}

struct MultiRadioSelectWithOptions<T: Hashable>: View {
    @Binding var selection: [T]
    let options: [RadioOption<T>]
    
    var body: some View {
        ForEach(options, id: \.self) { option in
            Card {
                HStack {
                    Image(systemName: selection.contains(option.value) ? "circle.fill" : "circle")
                        .foregroundStyle(.accent)
                    Text(option.label)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { toggle(option.value) }
            }
        }
    }
    
    private func toggle(_ option: T) {
        if let idx = selection.firstIndex(of: option) {
            selection.remove(at: idx)
        } else {
            selection.append(option)
        }
    }
}
