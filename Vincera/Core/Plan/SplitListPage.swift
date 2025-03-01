//
//  SplitListPage.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI
import Charts


struct SplitListPage: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  
  var body: some View {
    List {
      if !sStore.splits.isEmpty {
        Section("Custom Splits") {
          ForEach($sStore.splits) { $split in
            SplitCell(split: $split)
              .plainListStyle
          }
        }
      }
      Section("Vincera Splits") {
        ForEach(VINCERA_SPLITS) { split in
          SplitCell(split: Binding(get: { split }, set: { _ in }))
            .plainListStyle
        }
      }
    }
    .listRowSpacing(16)
    .navigationTitle("Splits")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct SplitCell: View {
  @EnvironmentObject private var router: Router
  @EnvironmentObject private var sStore: SplitStore
  @EnvironmentObject private var eStore: ExerciseStore
  @Binding var split: Split
  var isListItem: Bool = true
  
  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack {
          if isListItem {
            Button { handleSelect() } label: {
              Image(systemName: split.id == sStore.current?.id ? "circle.fill" : "circle")
                .foregroundStyle(.accent)
            }
          }
          Text(split.name)
            .fontWeight(.semibold)
            .font(.title3)
          Spacer()
          Menu("", systemImage: "ellipsis.circle") {
            if isListItem {
              Button { handleSelect() } label: {
                Label("Select", systemImage: "checklist")
              }
            }
            Button { router.goTo(.splitEditor(split)) } label: {
              Label("Edit", systemImage: "pencil")
            }
            Button { handleShare() } label: {
              Label("Share", systemImage: "square.and.arrow.up")
            }
            if !split.isBuiltin() {
              Button(role: .destructive) { handleDelete() } label: {
                Label("Delete", systemImage: "trash")
              }
            }
          }
          .font(.system(size: 16))
        }
        Text(split.description)
          .font(.caption)
          .foregroundStyle(.secondary)
        Divider()
        ForEach(split.days) { day in
          VStack(alignment: .leading) {
            HStack {
              RoundedRectangle(cornerRadius: 4)
                .fill(Color.fromHex(day.color))
                .frame(width: 16, height: 16)
              Text(day.name)
              Text("•")
                .font(.caption)
                .foregroundStyle(.secondary)
              Text(day.exercises.getBodyParts(eStore))
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            Text(day.description)
              .font(.caption)
              .foregroundStyle(.secondary)
          }
        }
      }
      Divider().padding(.vertical, 12)
      VStack(alignment: .leading) {
        HStack {
          Image(systemName: "scalemass.fill")
          Text("Volume / Body Part")
            .fontWeight(.semibold)
        }
        .font(.subheadline)
        VolumePieChart(volume: split.getVolume(eStore))
      }
      .onTapGesture { router.goTo(.splitEditor(split)) }
    }
    .padding()
    .backgroundRect(radius: 16, fill: .regularMaterial)
  }
  
  func handleSelect() {
    do {
      if split.id == sStore.current?.id {
        try sStore.selectSplit(nil)
      } else {
        try sStore.selectSplit(split)
      }
    } catch {
      router.notify(.danger, "Error selecting \(split.name)")
    }
  }
  
  func handleShare() {
    SplitSharingManager.shared.shareSplit(from: split)
  }
  
  func handleDelete() {
    do {
      try sStore.deleteSplit(split)
    } catch {
      router.notify(.danger, "Error deleting \(split.name)")
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
  SplitListPage()
}
