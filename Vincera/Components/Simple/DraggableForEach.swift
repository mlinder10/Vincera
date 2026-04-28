//
//  DraggableForEach.swift
//  Vincera
//
//  Created by Matt Linder on 3/21/26.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate struct DropViewDelegate<T: Equatable>: DropDelegate {
    let destinationItem: T
    @Binding var items: [T]
    @Binding var draggedItem: T?
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Swap Items
        if let draggedItem {
            let fromIndex = items.firstIndex(of: draggedItem)
            if let fromIndex {
                let toIndex = items.firstIndex(of: destinationItem)
                if let toIndex, fromIndex != toIndex {
                    withAnimation {
                        self.items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: (toIndex > fromIndex ? (toIndex + 1) : toIndex))
                    }
                }
            }
        }
    }
}

struct DraggableForEach<T: Equatable & Identifiable, Content: View>: View {
    @State private var draggedItem: T?
    @State private var targetItem: T?
    @Binding var items: [T]
    let withDividers: Bool
    let disabled: Bool
    @ViewBuilder var makeContent: (T) -> Content
    
    
    init(
        _ items: Binding<[T]>,
        withDividers: Bool = false,
        disabled: Bool = false,
        makeContent: @escaping (T) -> Content
    ) {
        self._items = items
        self.withDividers = withDividers
        self.disabled = disabled
        self.makeContent = makeContent
    }
    
    var body: some View {
        ForEach(items) { item in
            if disabled { makeContent(item) }
            else { enabledItemView(item) }
            if withDividers && !(items.last == item) {
                Divider()
                    .padding(.vertical, 8)
            }
        }
    }
    
    private func enabledItemView(_ item: T) -> some View {
        makeContent(item)
            .onDrag {
                self.draggedItem = item
                return NSItemProvider()
            }
            .onDrop(
                of: [.text],
                delegate: DropViewDelegate(
                    destinationItem: item,
                    items: $items,
                    draggedItem: $draggedItem
                )
            )
    }
}
