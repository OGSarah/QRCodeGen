//
//  ContentView.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var inputText: String = ""
    @State private var selectedECL: ErrorCorrectionLevel = .M
    @State private var qrImage: Image?
    @State private var qrUIImage: UIImage? // for sharing/saving/copying
    @State private var isGenerating = false
    @State private var generatorTask: Task<Void, Never>? // for debouncing/cancellation
    @State private var generationError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter text to encode", text: $inputText, axis: .vertical)
                        .textInputAutocapitalization(.never)
                        .lineLimit(5)
                        .submitLabel(.done)
                        .accessibilityLabel("QR code input text")
                        .accessibilityHint("Enter the text or URL you want to encode into a QR code. Supports multi-line input.")
                        .overlay(alignment: .trailing) {
                            HStack(spacing: 8) {
                                if !inputText.isEmpty {
                                    Button {
                                        inputText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Clear input")
                                    .accessibilityHint("Removes all text from the input field.")
                                }
                                Button {
                                    if let paste = UIPasteboard.general.string, !paste.isEmpty {
                                        inputText = paste
                                    }
                                } label: {
                                    Image(systemName: "doc.on.clipboard")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel("Paste from clipboard")
                                .accessibilityHint("Inserts the current clipboard content into the input field.")
                            }
                            .padding(.trailing, 6)
                        }
                } header: {
                    Label("Input", systemImage: "rectangle.and.pencil.and.ellipsis")
                        .accessibilityAddTraits(.isHeader)
                }

                Section {
                    Picker("Level", selection: $selectedECL) {
                        ForEach(ErrorCorrectionLevel.allCases) { level in
                            Text(level.description)
                                .tag(level)
                                .accessibilityLabel(level.description)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Error Correction Level")
                    .accessibilityHint("Choose how resiliant the QR code should be to damage. Higher levels use more space but are more resiliant.")
                } header: {
                    Label("Error Correction Level", systemImage: "gauge.with.needle")
                        .accessibilityAddTraits(.isHeader)
                } footer: {
                    Text("Higher levels make the QR code more resilient to damage.")
                        .font(.footnote)
                        .accessibilityLabel("Higher error correction levels increase reliability but make the QR code denser.")
                }

                Section {
                    Button {
                        generateQRCode(immediate: true)
                    } label: {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "qrcode")
                            }
                            Text(isGenerating ? "Generating…" : "Generate QR Code")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonStyle(.glass)
                    .glassEffect(.regular.tint(.blue).interactive())
                    .disabled(isGenerating)
                    .accessibilityHint("Creates a QR code from the current input text using the selected error correction level.")
                    .accessibilityLabel(isGenerating ? "Generating QR code" : "Generate QR code")

                    if let error = generationError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                            .accessibilityLabel("Generation error: \(error)")
                    }
                }

                if let image = qrImage {
                    Section {
                        image
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                            .accessibilityLabel("Generated QR code")
                            .accessibilityHint("Double-tap and hold to open actions: copy, save, or share.")
                            .contextMenu {
                                Button {
                                    copyImageToPasteboard()
                                } label: {
                                    Label("Copy Image", systemImage: "doc.on.doc")
                                }
                                .accessibilityHint("Copies the QR code image to the clipboard.")

                                Button {
                                    saveToPhotos()
                                } label: {
                                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                                }
                                .accessibilityHint("Saves the QR code to your photo library.")

                                if let ui = qrUIImage {
                                    ShareLink(item: Image(uiImage: ui), preview: SharePreview("QR Code", image: Image(uiImage: ui))) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .accessibilityHint("Opens the share sheet to send the QR code.")
                                }
                            }
                    } header: {
                        Label("Your QR Code", systemImage: "qrcode.viewfinder")
                            .accessibilityAddTraits(.isHeader)
                    } footer: {
                        Text("Tap and hold to share or save.")
                            .font(.caption)
                            .accessibilityLabel("Long press the QR code to copy, save, or share it.")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("QR Code Generator")
            .accessibilityLabel("QR Code Generator App")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if let paste = UIPasteboard.general.string, !paste.isEmpty {
                            inputText = paste
                        }
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    .accessibilityHint("Pastes clipboard content into the input field.")

                    if !inputText.isEmpty {
                        Button {
                            inputText = ""
                        } label: {
                            Label("Clear", systemImage: "xmark.circle")
                        }
                        .accessibilityHint("Clears the input text.")
                    }

                    if let ui = qrUIImage {
                        ShareLink(item: Image(uiImage: ui),
                                  preview: SharePreview("QR Code", image: Image(uiImage: ui))) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share QR code")
                        .accessibilityHint("Opens share sheet to send the generated QR code.")
                    }
                }
            }
            // Announce generation status
            .onChange(of: isGenerating) { _, newValue in
                if newValue {
                    UIAccessibility.post(notification: .announcement, argument: "Generating QR code…")
                }
            }
            .onChange(of: generationError) { _, newValue in
                if let error = newValue {
                    UIAccessibility.post(notification: .announcement, argument: "Error: \(error)")
                }
            }
        }
    }

    // MARK: Generation
    private func generateQRCode(immediate: Bool) {
        generatorTask?.cancel()
        generationError = nil

        let work = {
            isGenerating = true
            defer { isGenerating = false }

            let generator = QRCodeGenerator()
            do {
                let cgImage = try generator.generateQRCode(
                    from: inputText,
                    errorCorrectionLevel: selectedECL,
                    version: 4
                )
                let uiImage = UIImage(cgImage: cgImage)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                qrUIImage = uiImage
                qrImage = Image(uiImage: uiImage)
                UIAccessibility.post(notification: .announcement, argument: "QR code generated successfully.")
            } catch {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
                qrUIImage = nil
                qrImage = nil
                generationError = (error as NSError).localizedDescription
            }
        }

        if immediate {
            Task { @MainActor in work() }
        } else {
            generatorTask = Task { @MainActor in
                try? await Task.sleep(nanoseconds: 350_000_000) // debounce ~350ms
                if Task.isCancelled { return }
                work()
            }
        }
    }

    // MARK: Helpers
    private func copyImageToPasteboard() {
        guard let ui = qrUIImage else { return }
        UIPasteboard.general.image = ui
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "QR code copied to clipboard.")
    }

    private func saveToPhotos() {
        guard let ui = qrUIImage else { return }
        UIImageWriteToSavedPhotosAlbum(ui, nil, nil, nil)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        UIAccessibility.post(notification: .announcement, argument: "QR code saved to photos.")
    }

}

// MARK: Preview code
#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}
