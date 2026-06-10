//
//  AppDependencies.swift
//  QRCodeGen
//
//  The composition root. A plain struct is the whole "DI container" — the app
//  builds the live graph, tests build their own with mocks. No third-party
//  framework needed for a surface this small.
//

import SwiftData

@MainActor
struct AppDependencies {
    var generator: QRCodeGenerating
    var exporter: ImageExporting
    var store: HistoryStoring

    static func live(modelContext: ModelContext) -> AppDependencies {
        AppDependencies(
            generator: CoreImageQRCodeGenerator(),
            exporter: LiveImageExporter(),
            store: SwiftDataHistoryStore(context: modelContext)
        )
    }

    func makeViewModel() -> QRGeneratorViewModel {
        QRGeneratorViewModel(generator: generator, exporter: exporter, store: store)
    }
}
