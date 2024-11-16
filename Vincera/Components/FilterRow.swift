//
//  FilterRow.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/21/24.
//

import SwiftUI

struct FilterRow<T : Identifiable & Equatable & Hashable>: View {
  @Binding var selected: [T]
  let title: String
  let options: [T]
  
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

struct OptionCell<T: Identifiable & Hashable>: View {
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
        Text("\(option)".split(separator: /A-Z/).joined(separator: " ").capitalized)
          .selectable(isSelected)
      }
    }
  }
}
