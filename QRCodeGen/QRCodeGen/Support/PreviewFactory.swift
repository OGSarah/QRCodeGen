//
// PreviewFactory.swift
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
