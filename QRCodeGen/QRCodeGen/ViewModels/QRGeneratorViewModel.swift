//
// QRGeneratorViewModel.swift
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

import Observation
import SwiftUI

@MainActor
@Observable
final class QRGeneratorViewModel {
    /// Lifecycle of a generation request, surfaced to the view for status,
    /// haptics, and accessibility announcements.
    enum Phase: Equatable {
        case idle
        case generating
        case success
        case failure(String)
    }

    // MARK: Inputs (bound from the view)
    var inputText = ""
    var errorCorrectionLevel: ErrorCorrectionLevel = .M
    var appearance: QRAppearance = .default

    // MARK: Output state
    private(set) var renderedImage: UIImage?
    private(set) var phase: Phase = .idle
    private(set) var history: [QRHistoryEntry] = []

    // MARK: Derived
    /// Single source of truth: the SwiftUI image is derived, never stored separately.
    var displayImage: Image? { renderedImage.map { Image(uiImage: $0) } }
    var isGenerating: Bool { phase == .generating }
    var errorMessage: String? {
        if case let .failure(message) = phase { return message }
        return nil
    }

    // MARK: Dependencies
    private let generator: QRCodeGenerating
    private let exporter: ImageExporting
    private let store: HistoryStoring
    /// In-flight generation. Exposed (read-only) so tests can deterministically
    /// await completion rather than polling.
    private(set) var generationTask: Task<Void, Never>?

    /// Debounce window for reactive (non-immediate) generation.
    private static let debounce = Duration.milliseconds(350)
    private static let historyLimit = 25

    init(generator: QRCodeGenerating, exporter: ImageExporting, store: HistoryStoring) {
        self.generator = generator
        self.exporter = exporter
        self.store = store
    }

    func onAppear() {
        reloadHistory()
    }

    // MARK: Generation

    /// Generates a QR code from the current inputs. When `immediate` is false the
    /// work is debounced, so rapid edits coalesce into a single render.
    ///
    /// `persist` records a history entry on success. Only an explicit Generate
    /// (or restore) commits to history; live restyling via `regenerateIfNeeded`
    /// passes `false` so tweaking the appearance before tapping Generate doesn't
    /// litter history with intermediate variations.
    func generate(immediate: Bool, persist: Bool = true) {
        generationTask?.cancel()
        let request = QRCodeRequest(
            text: inputText,
            errorCorrectionLevel: errorCorrectionLevel,
            appearance: appearance
        )
        generationTask = Task { [weak self] in
            guard let self else { return }
            if !immediate {
                try? await Task.sleep(for: Self.debounce)
                if Task.isCancelled { return }
            }
            await self.run(request, persist: persist)
        }
    }

    /// Re-renders (debounced) only when a code already exists, so changing the
    /// error-correction level or appearance restyles the current code without
    /// generating one from empty/unconfirmed input. The restyle is never
    /// recorded in history — only tapping Generate commits an entry.
    func regenerateIfNeeded() {
        guard renderedImage != nil else { return }
        generate(immediate: false, persist: false)
    }

    private func run(_ request: QRCodeRequest, persist: Bool) async {
        phase = .generating
        do {
            let cgImage = try await generator.makeImage(for: request)
            if Task.isCancelled { return }
            renderedImage = UIImage(cgImage: cgImage)
            phase = .success
            if persist {
                self.persist(request)
            }
        } catch {
            renderedImage = nil
            phase = .failure(message(for: error))
        }
    }

    private func message(for error: Error) -> String {
        (error as? QRCodeError)?.errorDescription ?? error.localizedDescription
    }

    /// Renders an arbitrary request to an image without touching the editor's
    /// own output state. Used by the history detail screen to preview a saved
    /// entry independently of whatever is currently in the editor.
    func image(for request: QRCodeRequest) async throws -> UIImage {
        let cgImage = try await generator.makeImage(for: request)
        return UIImage(cgImage: cgImage)
    }

    // MARK: Export

    func copyImage() {
        guard let renderedImage else { return }
        exporter.copyToPasteboard(renderedImage)
    }

    func saveToPhotos() async {
        guard let renderedImage else { return }
        do {
            try await exporter.saveToPhotos(renderedImage)
        } catch {
            phase = .failure(message(for: error))
        }
    }

    // MARK: History

    func reloadHistory() {
        history = (try? store.recentEntries(limit: Self.historyLimit)) ?? []
    }

    func delete(_ entry: QRHistoryEntry) {
        try? store.delete(entry)
        reloadHistory()
    }

    /// Restores an entry's inputs into the editor and regenerates immediately.
    func restore(_ entry: QRHistoryEntry) {
        let request = entry.request
        inputText = request.text
        errorCorrectionLevel = request.errorCorrectionLevel
        appearance = request.appearance
        generate(immediate: true)
    }

    private func persist(_ request: QRCodeRequest) {
        guard !request.text.isEmpty else { return }
        try? store.add(request, createdAt: .now)
        reloadHistory()
    }
}
