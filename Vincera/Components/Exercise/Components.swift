//
//  Components.swift
//  Vincera
//
//  Created by Matt Linder on 3/25/26.
//

import SwiftUI

struct SetTypeView: View {
    @Binding var type: SetType
    let index: Int
    var disabled = false
    
    var body: some View {
        Group {
            if disabled { labelView }
            else { enabledView }
        }
    }
    
    private var labelView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(type.color)
                .frame(width: 32, height: 32)
            Text(type == .normal ? "\(index)" : type.letter)
        }
    }
    
    private var enabledView: some View {
        Menu {
            Picker(selection: $type, label: EmptyView()) {
                ForEach(SetType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized)
                        .tag(type.rawValue)
                }
            }
            .pickerStyle(.inline)
        } label: {
            labelView
        }
        .foregroundStyle(.foreground)
    }
}

struct TabIndexView: View {
    let index: Int?
    let total: Int
    
    var body: some View {
        HStack {
            ForEach(0..<total, id: \.self) { tab in
                Rectangle()
                    .fill(isCurrentTab(tab) ? .accent : .backgroundSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: isCurrentTab(tab) ? 4 : 2)
            }
        }
    }
    
    func isCurrentTab(_ tab: Int) -> Bool {
        if index == nil && tab == 0 { return true }
        return index == tab
    }
}
