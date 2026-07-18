//
//  DeleteButton.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI

struct DeleteButton: View {
    @EnvironmentObject private var store: DataStore
    
    var body: some View {
        BrandButton("Delete Data", role: .destructive, action: handleDelete)
            .withAlert(title: "Delete All Data?")
            .secondary
    }
    
    private func handleDelete() {
        store.deleteData(for: TransferableData.allCases)
    }
}
