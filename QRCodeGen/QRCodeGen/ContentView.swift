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
                        .accessibilityIdentifier("inputTextField")
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
                                    .accessibilityLabel("Clear text")
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
                                .accessibilityLabel("Paste")
                            }
                            .padding(.trailing, 6)
                        }
                } header: {
                    Label("Input", systemImage: "rectangle.and.pencil.and.ellipsis")
                        .padding(.top, 20)
                }

                Section {
                    Picker("Level", selection: $selectedECL) {
                        ForEach(ErrorCorrectionLevel.allCases) { level in
                            Text(level.description)
                                .tag(level)
                                .accessibilityIdentifier("eclSegment_\(String(describing: level))")
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(-5)
                    .accessibilityIdentifier("eclSegmentedControl")
                } header: {
                    Label("Error Correction Level", systemImage: "gauge.with.needle")
                        .padding(.top, 5)
                } footer: {
                    Text("Higher levels make the QR code more resilient to damage.")
                        .padding(.bottom, 10)
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
                    .accessibilityHint("Runs debug generation and prints diagnostic info")
                    .buttonStyle(.glass)
                    .glassEffect(.regular.tint(.blue).interactive())
                    .disabled(isGenerating)
                    .accessibilityHint("Generates a QR code for the entered text")
                    .accessibilityIdentifier("generateButton")

                    if let error = generationError {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
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
                            .accessibilityIdentifier("qrImageView")
                            .contextMenu {
                                Button {
                                    copyImageToPasteboard()
                                } label: {
                                    Label("Copy Image", systemImage: "doc.on.doc")
                                }
                                .accessibilityIdentifier("contextCopyImage")

                                Button {
                                    saveToPhotos()
                                } label: {
                                    Label("Save to Photos", systemImage: "square.and.arrow.down")
                                }
                                .accessibilityIdentifier("contextSaveToPhotos")

                                if let ui = qrUIImage {
                                    ShareLink(item: Image(uiImage: ui), preview: SharePreview("QR Code", image: Image(uiImage: ui))) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    .accessibilityIdentifier("contextShare")
                                }
                            }
                    } header: {
                        Label("Your QR Code", systemImage: "qrcode.viewfinder")
                            .padding(.top, 10)
                    } footer: {
                        Text("Tap and hold to share or save.")
                            .font(.caption)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("QR Code Generator")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        if let paste = UIPasteboard.general.string, !paste.isEmpty {
                            inputText = paste
                        }
                    } label: {
                        Label("Paste", systemImage: "doc.on.clipboard")
                    }
                    .accessibilityIdentifier("toolbarPasteButton")

                    if !inputText.isEmpty {
                        Button {
                            inputText = ""
                        } label: {
                            Label("Clear", systemImage: "xmark.circle")
                        }
                        .accessibilityIdentifier("toolbarClearButton")
                    }

                    if let ui = qrUIImage {
                        ShareLink(item: Image(uiImage: ui),
                                  preview: SharePreview("QR Code", image: Image(uiImage: ui))) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .accessibilityLabel("Share")
                        .accessibilityIdentifier("toolbarShareButton")
                    }
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
    }

    private func saveToPhotos() {
        guard let ui = qrUIImage else { return }
        UIImageWriteToSavedPhotosAlbum(ui, nil, nil, nil)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
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

