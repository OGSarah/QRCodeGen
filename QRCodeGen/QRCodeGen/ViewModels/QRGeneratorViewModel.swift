//
//  QRGeneratorViewModel.swift
//  QRCodeGen
//
//  Owns all state and behavior for the generator screen. Replaces the pile of
//  `@State` that previously lived in `ContentView`, giving a single source of
//  truth for the rendered image, debounced generation, and history — all
//  unit-testable through injected protocol dependencies.
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
    func generate(immediate: Bool) {
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
            await self.run(request)
        }
    }

    /// Re-renders (debounced) only when a code already exists, so changing the
    /// error-correction level or appearance restyles the current code without
    /// generating one from empty/unconfirmed input.
    func regenerateIfNeeded() {
        guard renderedImage != nil else { return }
        generate(immediate: false)
    }

    private func run(_ request: QRCodeRequest) async {
        phase = .generating
        do {
            let cgImage = try await generator.makeImage(for: request)
            if Task.isCancelled { return }
            renderedImage = UIImage(cgImage: cgImage)
            phase = .success
            persist(request)
        } catch {
            renderedImage = nil
            phase = .failure(message(for: error))
        }
    }

    private func message(for error: Error) -> String {
        (error as? QRCodeError)?.errorDescription ?? error.localizedDescription
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
