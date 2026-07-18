//
//  ImportButton.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI

struct ImportButton: View {
    @EnvironmentObject private var store: DataStore
    @State private var isImporting = false
    
    var body: some View {
        BrandButton("Import Data") { isImporting = true }
            .secondary
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                onCompletion: handleImport
            )
    }
    
    private func handleImport(_ result: Result<URL, any Error>) {
        do {
            switch result {
            case .success(let url): try store.importData(from: url)
            case .failure(let error): throw error
            }
            Router.shared.toast("Data imported", type: .success)
        } catch {
            print(error.localizedDescription)
            Router.shared.toast("Failed to import data", type: .error)
        }
    }
}
