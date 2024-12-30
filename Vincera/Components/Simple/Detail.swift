//
//  Detail.swift
//  Vincera
//
//  Created by Matt Linder on 11/4/24.
//

import SwiftUI

struct Details: Identifiable, Equatable {
  let id = UUID().uuidString
  let icon: String
  let title: String
  let description: String
  
  static func == (lhs: Details, rhs: Details) -> Bool {
    return lhs.id == rhs.id
  }
}

struct DetailsView: View {
  @EnvironmentObject private var router: Router
  let details: Details
  
  var body: some View {
    VStack(spacing: 16) {
      HStack {
        Button {
          withAnimation {
            router.details = nil
          }
        } label: {
          Text("Dismiss")
        }
        Spacer()
      }
      HStack {
        Image(systemName: details.icon)
        Text(details.title)
      }
      .font(.title3)
      .fontWeight(.bold)
      Text(details.description)
      Spacer()
    }
    .padding()
    .frame(maxHeight: 400)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(Color.background)
    )
  }
}

struct DetailsDisplayer: ViewModifier {
  @EnvironmentObject var router: Router
  
  func body(content: Content) -> some View {
    content
      .overlay(alignment: .bottom) {
        ZStack(alignment: .bottom) {
          if router.details != nil {
            Color.black.opacity(0.2)
              .onTapGesture {
                withAnimation {
                  router.details = nil
                }
              }
          }
          if let details = router.details {
            DetailsView(details: details)
              .transition(.move(edge: .bottom))
              .animation(.snappy(duration: 0.2), value: router.details)
          }
        }
        .ignoresSafeArea()
      }
  }
}

extension View {
  var detailDisplayer: some View {
    modifier(DetailsDisplayer())
  }
}
