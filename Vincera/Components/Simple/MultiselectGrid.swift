//
//  MultiselectGrid.swift
//  Vincera
//
//  Created by Matt Linder on 3/29/26.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = flow(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = flow(proposal: proposal, subviews: subviews)
        for (index, point) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
        }
    }

    private func flow(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var cursor = CGPoint.zero
        var positions: [CGPoint] = []
        var maxX: CGFloat = 0
        var maxY: CGFloat = 0
        let maxWidth = proposal.width ?? .infinity

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if cursor.x + size.width > maxWidth {
                cursor.x = 0
                cursor.y = maxY + spacing
            }
            positions.append(cursor)
            cursor.x += size.width + spacing
            maxX = max(maxX, cursor.x)
            maxY = max(maxY, cursor.y + size.height)
        }
        return (CGSize(width: maxX, height: maxY), positions)
    }
}

struct MultiselectGrid<T: StringRepresentable & Hashable & Identifiable>: View {
    @Binding var selected: [T]
    let options: [T]
    var max: Int?
    var showAllButton = false
    
    var body: some View {
        FlowLayout {
            ForEach(options) { option in
                Card(.capsule, padding: 8) {
                    HStack {
                        Image(systemName: selected.contains(option) ? "circle.fill" : "circle")
                            .foregroundStyle(.accent)
                        Text(option.string)
                    }
                    .font(.caption)
                }
                .contentShape(Capsule())
                .onTapGesture { handleToggle(option) }
            }
            if showAllButton {
                Card(.capsule, padding: 8) {
                    HStack {
                        Image(systemName: selected.count == options.count ? "circle.fill" : "circle")
                            .foregroundStyle(.accent)
                        Text("All")
                    }
                    .font(.caption)
                }
                .contentShape(Capsule())
                .onTapGesture { handleToggleAll() }
            }
        }
    }
    
    private func handleToggle(_ option: T) {
        if let i = selected.firstIndex(of: option) {
            selected.remove(at: i)
        } else {
            if let max, selected.count == max {
                Haptics.notify(.warning)
                return
            }
            selected.append(option)
        }
    }
    
    private func handleToggleAll() {
        if selected.count == options.count {
            selected = []
        } else {
            selected = options
        }
    }
}

#Preview {
    @Previewable @State var selected = [EquipmentType]()
    Card {
        VStack {
            HStack {
                Spacer()
            }
            MultiselectGrid(
                selected: $selected,
                options: EquipmentType.allCases
            )
        }
    }
    .padding(.horizontal)
}
