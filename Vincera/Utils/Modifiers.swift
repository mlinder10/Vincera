//
//  Modifiers.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import Foundation
import SwiftUI

extension Text {
    func selectable(_ active: Bool, _ thickBackground: Bool = false) -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 6)
            .foregroundStyle(active ? Color.background : Color.primary)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(active ? Color.accent : thickBackground ? Color.background.opacity(0.6) : Color.clear)
            )
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(.ultraThickMaterial)
            )
    }
}

extension View {
    func backgroundRect<T: ShapeStyle>(radius: CGFloat, fill: T) -> some View {
        self.background(RoundedRectangle(cornerRadius: radius).fill(fill))
    }
    
    var bordered: some View {
        self
            .padding(.vertical, 8)
            .foregroundStyle(.accent)
            .backgroundRect(radius: 8, fill: .ultraThickMaterial)
    }
    
    var borderedProminent: some View {
        self
            .padding(.vertical, 8)
            .foregroundStyle(Color.background)
            .backgroundRect(radius: 8, fill: Color.accentColor)
    }
    
    var plainListStyle: some View {
        self
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
    }
    
    func asStretchyHeader(startingHeight: CGFloat) -> some View {
        modifier(StretchyHeaderModifier(startingHeight: startingHeight))
    }
    
    func readingFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (_ frame: CGRect) -> ()) -> some View {
        background(FrameReader(coordinateSpace: coordinateSpace, onChange: onChange))
    }
    
    var hiddenNavigation: some View {
        self
            .navigationBarBackButtonHidden()
            .toolbar(.hidden, for: .navigationBar)
            .overlay(alignment: .topLeading) {
                Button { Router.shared.pop() } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(4)
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
                .padding(.leading)
            }
    }
    
    // MARK: mocking
    
    var mockEnvironment: some View {
        self
            .environmentObject(MOCK_DATA_STORE)
    }
    
    var mockNavigation: some View {
        NavigationStack {
            self
        }
    }
    
    func mockNavigation(path: Binding<NavigationPath>) -> some View {
        NavigationStack(path: path) {
            self
        }
    }
}

struct FrameReader : View {
    let coordinateSpace: CoordinateSpace
    let onChange: (_ frame: CGRect) -> ()
    
    public init(coordinateSpace: CoordinateSpace, onChange: @escaping (_ frame: CGRect) -> Void) {
        self.coordinateSpace = coordinateSpace
        self.onChange = onChange
    }
    
    public var body: some View {
        GeometryReader{ geo in
            Text("")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    onChange(geo.frame(in: coordinateSpace))
                }
                .onChange(of: geo.frame(in: coordinateSpace)) { oldValue, newValue in
                    onChange(newValue)
                }
        }
    }
}

struct StretchyHeaderModifier : ViewModifier {
    var startingHeight: CGFloat = 300
    var coordinateSpace: CoordinateSpace = .global
    
    func body(content: Content) -> some View {
        GeometryReader(content: { geometry in
            content
                .frame(width: geometry.size.width, height: stretchedHeight(geometry))
                .clipped()
                .offset(y: stretchedOffset(geometry))
        })
        .frame(height: startingHeight)
    }
    
    private func yOffset(_ geo: GeometryProxy) -> CGFloat {
        return geo.frame(in: coordinateSpace).minY
    }
    
    private func stretchedHeight(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? (startingHeight + offset) : startingHeight
    }
    
    private func stretchedOffset(_ geo: GeometryProxy) -> CGFloat {
        let offset = yOffset(geo)
        return offset > 0 ? -offset : 0
    }
}

