//
// QRGeneratorViewModelTests.swift
// QRCodeGenTests
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
@testable import QRCodeGen
import Testing

@MainActor
@Suite("QRGeneratorViewModel")
struct QRGeneratorViewModelTests {
    private struct SUT {
        let viewModel: QRGeneratorViewModel
        let exporter: MockImageExporter
        let store: MockHistoryStore
    }

    private func makeSUT(generatorOutcome: MockQRCodeGenerator.Outcome = .success) -> SUT {
        let exporter = MockImageExporter()
        let store = MockHistoryStore()
        let viewModel = QRGeneratorViewModel(
            generator: MockQRCodeGenerator(outcome: generatorOutcome),
            exporter: exporter,
            store: store
        )
        return SUT(viewModel: viewModel, exporter: exporter, store: store)
    }

    @Test("Successful generation renders an image and records history")
    func successfulGeneration() async {
        let sut = makeSUT()
        sut.viewModel.inputText = "Hello"
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        #expect(sut.viewModel.phase == .success)
        #expect(sut.viewModel.renderedImage != nil)
        #expect(sut.store.entries.count == 1)
        #expect(sut.viewModel.history.count == 1)
    }

    @Test("Tapping Generate again after a restyle records a second entry")
    func secondGenerateRecordsHistory() async {
        let sut = makeSUT()
        sut.viewModel.inputText = "Hello"
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        // Restyling alone must not persist (it only drives the color preview).
        sut.viewModel.appearance.modulePixelSize = 14
        sut.viewModel.regenerateIfNeeded()
        await sut.viewModel.generationTask?.value
        #expect(sut.store.entries.count == 1)

        // Tapping Generate commits the restyled code as a new history entry.
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value
        #expect(sut.store.entries.count == 2)
        #expect(sut.viewModel.history.count == 2)
    }

    @Test("Generation failure clears the image and surfaces the error")
    func generationFailure() async {
        let sut = makeSUT(generatorOutcome: .failure(.generationFailed))
        sut.viewModel.inputText = "Hello"
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        #expect(sut.viewModel.renderedImage == nil)
        #expect(sut.viewModel.phase == .failure(QRCodeError.generationFailed.errorDescription ?? ""))
        #expect(sut.viewModel.errorMessage == QRCodeError.generationFailed.errorDescription)
        #expect(sut.store.entries.isEmpty)
    }

    @Test("Empty input is generated but never persisted")
    func emptyInputNotPersisted() async {
        let sut = makeSUT()
        sut.viewModel.inputText = ""
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        #expect(sut.viewModel.phase == .success)
        #expect(sut.store.entries.isEmpty)
    }

    @Test("Copy forwards the rendered image to the exporter")
    func copyForwardsImage() async {
        let sut = makeSUT()
        sut.viewModel.inputText = "Hello"
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        sut.viewModel.copyImage()
        #expect(sut.exporter.copiedImages.count == 1)
    }

    @Test("A failed save is surfaced as a failure phase")
    func saveFailureSurfacesError() async {
        let sut = makeSUT()
        sut.exporter.saveError = .photoLibraryAccessDenied
        sut.viewModel.inputText = "Hello"
        sut.viewModel.generate(immediate: true)
        await sut.viewModel.generationTask?.value

        await sut.viewModel.saveToPhotos()
        #expect(sut.viewModel.errorMessage == QRCodeError.photoLibraryAccessDenied.errorDescription)
    }

    @Test("Restore loads an entry's inputs and regenerates")
    func restoreLoadsAndRegenerates() async throws {
        let sut = makeSUT()
        try sut.store.add(QRCodeRequest(text: "Saved", errorCorrectionLevel: .H), createdAt: .now)
        let entry = try #require(sut.store.entries.first)

        sut.viewModel.restore(entry)
        await sut.viewModel.generationTask?.value

        #expect(sut.viewModel.inputText == "Saved")
        #expect(sut.viewModel.errorCorrectionLevel == .H)
        #expect(sut.viewModel.renderedImage != nil)
    }

    @Test("regenerateIfNeeded does nothing without an existing image")
    func regenerateIfNeededNoOpWhenIdle() {
        let sut = makeSUT()
        sut.viewModel.regenerateIfNeeded()
        #expect(sut.viewModel.generationTask == nil)
        #expect(sut.viewModel.phase == .idle)
    }

    @Test("Deleting an entry removes it from history")
    func deleteRemovesEntry() async throws {
        let sut = makeSUT()
        try sut.store.add(QRCodeRequest(text: "Doomed", errorCorrectionLevel: .M), createdAt: .now)
        sut.viewModel.reloadHistory()
        let entry = try #require(sut.viewModel.history.first)

        sut.viewModel.delete(entry)
        #expect(sut.viewModel.history.isEmpty)
    }
}
