//
//  ExportButton.swift
//  Vincera
//
//  Created by Matt Linder on 5/22/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    static var writableContentTypes: [UTType] { [.json] }
    
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
}

struct ExportButton: View {
    @EnvironmentObject private var store: DataStore
    @State private var isPresented = false
    @State private var isExporting = false
    @State private var objects = [TransferableData]()
    @State private var document: JSONDocument?
    
    var body: some View {
        BrandButton("Export Data") { isPresented = true }
            .secondary
            .sheet(isPresented: $isPresented) {
                sheet
            }
    }
    
    @ViewBuilder
    private var sheet: some View {
        NavigationStack {
            VStack {
                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("Your Data")
                                .fontWeight(.semibold)
                            Text("Choose the data you want to export")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        
                        VStack {
                            MultiRadioSelectWithOptions(
                                selection: $objects,
                                options: TransferableData.allCases.map({
                                    RadioOption($0.label, value: $0)
                                })
                            )
                        }
                        
                        BrandButton("Export", action: handleExport)
                            .primary
                            .disabled(objects.isEmpty)
                    }
                }
                .padding(.horizontal, PADDING_INLINE)
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
        }
        .fileExporter(
            isPresented: $isExporting,
            document: document,
            contentType: .json,
            defaultFilename: "Vincera_Backup",
            onCompletion: handleCompletion
        )
    }
    
    private func handleExport() {
        do {
            let data = try store.exportData(from: objects)
            document = JSONDocument(data: data)
            isExporting = true
        } catch {
            Router.shared.toast("Failed to encode data", type: .error)
        }
    }
    
    private func handleCompletion(_ result: Result<URL, any Error>) {
        switch result {
        case .success:
            isPresented = false
            Router.shared.toast("Data exported", type: .success)
        case .failure:
            Router.shared.toast("Failed to export data", type: .error)
        }
    }
}

