//
//  CurrentSplitView.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI

struct CurrentSplitView: View {
    let split: Writers.Split
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(split.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(split.description)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(.tertiary)
                }
                
                Divider()
                
                VolumePieChart(
                    title: "Volume By Group",
                    subtitle: nil,
                    volume: split.getVolume(),
                    size: 160
                )
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Router.shared.push(SplitEditorRoute(split: split))
        }
    }
}
