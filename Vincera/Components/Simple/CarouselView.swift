//
//  InfiniteCarousel.swift
//
//
//  Created by Daniel Carvajal on 01-08-22.
//

import SwiftUI

public struct InfiniteCarousel<Content: View, T: Any>: View {
    
    // MARK: Properties
    @Environment(\.scenePhase) var scenePhase
    @Binding private var selectedTab: Int
    @State private var isScaleEnabled: Bool = true
    private let data: [T]
    private let content: (T) -> Content
    private let showAlternativeBanner: Bool
    private let height: CGFloat
    private let horizontalPadding: CGFloat
    private let cornerRadius: CGFloat
    private let transition: TransitionType
    private let onTabChange: (T) -> Void
    
    // MARK: Init
    public init(
        data: [T],
        selectedTab: Binding<Int>,
        height: CGFloat = 150,
        horizontalPadding: CGFloat = 30,
        cornerRadius: CGFloat = 10,
        transition: TransitionType = .scale,
        onTabChange: @escaping (T) -> Void = { _ in },
        @ViewBuilder content: @escaping (T) -> Content
    ) {
        // We repeat the first and last element and add them to the data array. So we have something like this:
        // [item 4, item 1, item 2, item 3, item 4, item 1]
        var modifiedData = data
        if let firstElement = data.first, let lastElement = data.last {
            modifiedData.append(firstElement)
            modifiedData.insert(lastElement, at: 0)
            showAlternativeBanner = false
        } else {
            showAlternativeBanner = true
        }
        self.data = modifiedData
        self.content = content
        self.height = height
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.transition = transition
        self.onTabChange = onTabChange
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            /*
             The data passed to ForEach is an array ([T]), but the actually data ForEach procesess is an array of tuples: [(1, data1),(2, data2), ...].
             With this, we have the data and its corresponding index, so we don't have the problem of the same id, because the real index for ForEach is using for identify the items is the index generated with the zip function.
             */
            ForEach(Array(zip(data.indices, data)), id: \.0) { index, item in
                GeometryReader { proxy in
                    let positionMinX = proxy.frame(in: .global).minX
                    
                    content(item)
                        .cornerRadius(cornerRadius)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .rotation3DEffect(transition == .rotation3D ? getRotation(positionMinX) : .degrees(0), axis: (x: 0, y: 1, z: 0))
                        .opacity(transition == .opacity ? getValue(positionMinX) : 1)
                        .scaleEffect(isScaleEnabled && transition == .scale ? getValue(positionMinX) : 1)
                        .padding(.horizontal, horizontalPadding)
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
        .onChange(of: selectedTab) { _, newValue in
            if newValue != 0 && newValue != data.count - 1 {
                onTabChange(data[newValue])
            }
            if showAlternativeBanner {
                guard newValue < data.count else {
                    withAnimation {
                        selectedTab = 0
                    }
                    return
                }
            } else {
                // If the index is the first item (which is the last one, but repeated) we assign the tab to the real item, no the repeated one)
                if newValue == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedTab = data.count - 2
                    }
                }
                
                // If the index is the last item (which is the first one, but repeated) we assign the tab to the real item, no the repeated one)
                if newValue == data.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedTab = 1
                    }
                }
            }
        }
        .onAppear {
            isScaleEnabled = true
        }
        .onWillDisappear {
            isScaleEnabled = false
        }
    }
}

// Helpers functions
extension InfiniteCarousel {
    
    // Get rotation for rotation3DEffect modifier
    private func getRotation(_ positionX: CGFloat) -> Angle {
        return .degrees(positionX / -10)
    }
    
    // Get the value for scale and opacity modifiers
    private func getValue(_ positionX: CGFloat) -> CGFloat {
        let scale = 1 - abs(positionX / UIScreen.main.bounds.width)
        return scale
    }
}

public enum TransitionType {
    case rotation3D, scale, opacity
}

// ===========================================

// Monitors the life cycles of view (onWillAppear or onWillDisappear)
private struct ViewLifeCycleHandler: UIViewControllerRepresentable {
    
    let onWillDisappear: () -> Void
    let onWillAppear: () -> Void
    
    func makeUIViewController(context: Context) -> UIViewController {
        ViewLifeCycleViewController(onWillDisappear: onWillDisappear, onWillAppear: onWillAppear)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

private class ViewLifeCycleViewController: UIViewController {
    let onWillDisappear: () -> Void
    let onWillAppear: () -> Void
    
    init(onWillDisappear: @escaping () -> Void, onWillAppear: @escaping () -> Void) {
        self.onWillDisappear = onWillDisappear
        self.onWillAppear = onWillAppear
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onWillDisappear()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        onWillAppear()
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        background(ViewLifeCycleHandler(onWillDisappear: perform, onWillAppear: {}))
    }
    func onWillAppear(_ perform: @escaping () -> Void) -> some View {
        background(ViewLifeCycleHandler(onWillDisappear: {}, onWillAppear: perform))
    }
}
