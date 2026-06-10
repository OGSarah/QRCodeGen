//
//  PreviewFactory.swift
//  QRCodeGen
//
//  Builds a fully-wired view model backed by an in-memory store for SwiftUI
//  previews, so the canvas never touches the on-disk history.
//

import SwiftData

@MainActor
enum PreviewFactory {
    static func viewModel() -> QRGeneratorViewModel {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: QRHistoryEntry.self, configurations: configuration) else {
            fatalError("Failed to build in-memory preview container")
        }
        return AppDependencies.live(modelContext: container.mainContext).makeViewModel()
    }
}
