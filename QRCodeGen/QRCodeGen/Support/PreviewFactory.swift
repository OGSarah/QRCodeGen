//
//  PreviewFactory.swift
//  QRCodeGen
//
//  Builds a fully-wired view model backed by an in-memory store for SwiftUI
//  previews, so the canvas never touches the on-disk history.
//

import Foundation
import SwiftData

@MainActor
enum PreviewFactory {
    /// An empty, fully-wired view model backed by an in-memory store.
    static func viewModel() -> QRGeneratorViewModel {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: QRHistoryEntry.self, configurations: configuration) else {
            fatalError("Failed to build in-memory preview container")
        }
        return AppDependencies.live(modelContext: container.mainContext).makeViewModel()
    }

    /// A view model pre-seeded with a generated code, so previews of the result
    /// and history sections render real content. Generation is async, so the
    /// content fills in shortly after the live preview appears.
    static func populatedViewModel() -> QRGeneratorViewModel {
        let viewModel = viewModel()
        viewModel.inputText = "https://www.apple.com"
        viewModel.generate(immediate: true)
        return viewModel
    }

    /// A standalone history entry for previewing the detail screen.
    static func sampleEntry() -> QRHistoryEntry {
        QRHistoryEntry(
            request: QRCodeRequest(
                text: "https://www.apple.com",
                errorCorrectionLevel: .M,
                appearance: .default
            ),
            createdAt: .now
        )
    }
}
