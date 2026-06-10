//
//  QRCodeGenApp.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//

import SwiftData
import SwiftUI

@main
struct QRCodeGenApp: App {
    private let container: ModelContainer?

    init() {
        // When this app is launched purely as the unit-test host, it must not
        // build its own SwiftData container: a process can only register one
        // container per @Model, and the tests create their own. (UI tests run
        // the app normally, so this guard does not affect them.)
        container = Self.isRunningUnitTests ? nil : Self.makeContainer()
    }

    var body: some Scene {
        WindowGroup {
            if let container {
                ContentView(
                    viewModel: AppDependencies.live(modelContext: container.mainContext).makeViewModel()
                )
                .modelContainer(container)
            } else {
                Color.clear
            }
        }
    }

    /// Builds the history container, degrading gracefully: if the on-disk store
    /// is unavailable, fall back to an in-memory store so the app still
    /// launches rather than crashing.
    private static func makeContainer() -> ModelContainer {
        if let onDisk = try? ModelContainer(for: QRHistoryEntry.self) {
            return onDisk
        }
        do {
            return try ModelContainer(
                for: QRHistoryEntry.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("Unable to create a model container: \(error)")
        }
    }

    private static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }
}
