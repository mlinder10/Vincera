//
//  SplitCell.swift
//  Vincera
//
//  Created by Matt Linder on 8/1/25.
//

import SwiftUI
import Charts

struct SplitCell: View {
    @EnvironmentObject private var store: DataStore
    @State private var isExpended = false
    let split: Writers.Split
    var isListItem = true
    
    var body: some View {
        Card {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    HStack {
                        if isListItem {
                            Button(
                                "",
                                systemImage: split.id == store.currentSplit?.id ? "circle.fill" : "circle",
                                action: handleSelect
                            )
                        }
                        Text(split.name)
                            .fontWeight(.semibold)
                            .font(.title3)
                        Spacer()
                        Menu("", systemImage: "ellipsis.circle") {
                            menuOptions
                        }
                        .font(.system(size: 16))
                    }
                    
                    Text(split.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.trailing, 64)
                    
                    Divider()
                    
                    ForEach(split.days) { day in
                        VStack(alignment: .leading) {
                            HStack {
                                let bodyparts = day.wrappers.flattened().getBodyParts()
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.fromHex(day.color))
                                    .frame(width: 16, height: 16)
                                Text(day.name)
                                if !bodyparts.isEmpty {
                                    Text("•")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(day.wrappers.flattened().getBodyParts())
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            if isExpended {
                                Text(day.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                if isExpended {
                    Divider().padding(.vertical, 12)
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "scalemass.fill")
                            Text("Volume / Body Part")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        VolumePieChart(volume: split.getVolume())
                    }
                }
                HStack {
                    Text(isExpended ? "Show Less" : "Show More")
                        .foregroundStyle(.accent)
                        .font(.caption)
                        .padding(.top, 8)
                        .onTapGesture { isExpended.toggle() }
                    Spacer()
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { handleSelect() }
    }
    
    private var menuOptions: some View {
        Group {
            if isListItem {
                Button("Select", systemImage: "checklist", action: handleSelect)
            }
            
            if !isSplitPremium(splitId: split.id) {
                Button("Copy Text", systemImage: "document.on.document") {
                    Clipboard.copy(split.formatted())
                    Router.shared.toast("Text copied to clipboard", type: .info)
                }
                
                Button("Edit", systemImage: "pencil") {
                    Router.shared.push(SplitEditorRoute(split: split))
                }
            }
            
            if !isSplitImmutable(splitId: split.id) {
                Button(
                    "Delete",
                    systemImage: "trash",
                    role: .destructive,
                    action: handleDelete
                )
            }
        }
    }
    
    private func handleSelect() {
        do {
            guard split.id != store.currentSplit?.id else { return }
            try store.selectSplit(split)
        } catch {
            Router.shared.toast("Error selecting \(split.name)", type: .error)
        }
    }
    
    private func handleDelete() {
        do {
            try store.deleteSplit(split)
        } catch {
            Router.shared.toast("Error deleting \(split.name)", type: .error)
        }
    }
}

struct VolumePieChart: View {
    let volume: [Volume]
    var size: CGFloat = 160
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                ForEach(volume.sortedByAvg()) { vol in
                    HStack {
                        Rectangle()
                            .fill(vol.bodyPart.color)
                            .frame(width: 8, height: 8)
                        Text(vol.bodyPart.rawValue.capitalized)
                            .font(.caption)
                        Text("\(volume.average(vol.bodyPart))%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Chart {
                ForEach(volume) { vol in
                    SectorMark(angle: .value(vol.bodyPart.rawValue, vol.sets))
                        .foregroundStyle(vol.bodyPart.color)
                }
            }
            .frame(height: size)
        }
    }
}

#Preview {
    SplitListScreen()
}
