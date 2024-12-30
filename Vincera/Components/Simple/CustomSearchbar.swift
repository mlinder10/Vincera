//
//  CustomSearchbar.swift
//  Vincera
//
//  Created by Matt Linder on 10/29/24.
//

import SwiftUI

struct CustomSearchbar: View {
  @Binding var searchText: String
  @State private var isEditing = false
  
  var body: some View {
    HStack {
      TextField("Search...", text: $searchText)
        .padding(8)
        .padding(.horizontal, 25)
        .background(Color(.systemGray5))
        .cornerRadius(8)
        .overlay(
          HStack {
            Image(systemName: "magnifyingglass")
              .foregroundColor(.gray)
              .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 8)
            
            if isEditing {
              Button { searchText = "" } label: {
                Image(systemName: "xmark.circle.fill")
                  .foregroundColor(.gray)
                  .padding(.trailing, 8)
              }
            }
          }
        )
        .onTapGesture { isEditing = true }
      
      if isEditing {
        Button("Cancel") {
          isEditing = false
          searchText = ""
          hideKeyboard()
        }
        .padding(.trailing, 8)
      }
    }
  }
  
  private func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
