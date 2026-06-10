//
// QRCodeGenApp.swift
// QRCodeGen
//
// MIT License
//
// Copyright (c) 2026 SarahUniverse
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
