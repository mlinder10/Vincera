//
//  SplitListScreen.swift
//  LiftLogs
//
//  Created by Matt Linder on 10/22/24.
//

import SwiftUI
import Charts

struct SplitListScreen: View {
    @EnvironmentObject private var productManager: ProductManager
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        List {
//            Section("Premium Splits") {
//                ForEach(PREMIUM_SPLITS) { split in
//                    PremiumSplitCell(split: split)
//                        .plainListStyle
//                }
//            }
            
            if !store.split.list.isEmpty {
                Section("Custom Splits") {
                    ForEach(store.split.list) { split in
                        SplitCell(split: split)
                            .plainListStyle
                    }
                }
            }
            
            Section("Vincera Splits") {
                ForEach(VINCERA_SPLITS) { split in
                    SplitCell(split: split)
                        .plainListStyle
                }
            }
        }
        .listRowSpacing(16)
        .navigationTitle("Splits")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func handleRestore() {
        Task {
            do {
                try await productManager.restorePurchases()
            } catch {
                Router.shared.toast("", type: .error)
            }
        }
    }
}

#Preview {
    SplitListScreen()
        .mockEnvironment
        .mockNavigation
}
