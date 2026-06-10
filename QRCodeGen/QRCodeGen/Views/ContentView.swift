//
//  ContentView.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//
//  Thin composition root for the generator screen. All state and behavior
//  live in `QRGeneratorViewModel`; this view wires sections together and
//  owns purely-presentational concerns (haptics, VoiceOver announcements).
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: QRGeneratorViewModel

    init(viewModel: QRGeneratorViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            List {
                QRInputSection(viewModel: viewModel)
                QRSettingsSection(viewModel: viewModel)
                QRAppearanceSection(viewModel: viewModel)
                generateSection
                QRResultSection(viewModel: viewModel)
                QRHistorySection(viewModel: viewModel)
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("QR Code Generator")
            .accessibilityLabel("QR Code Generator App")
            .toolbar { toolbarContent }
            .onChange(of: viewModel.phase) { _, phase in
                respond(to: phase)
            }
            .onAppear { viewModel.onAppear() }
        }
    }

    // MARK: Generate

    private var generateSection: some View {
        Section {
            Button {
                viewModel.generate(immediate: true)
            } label: {
                HStack {
                    if viewModel.isGenerating {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "qrcode")
                    }
                    Text(viewModel.isGenerating ? "Generating…" : "Generate QR Code")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glass)
            .glassEffect(.regular.tint(.blue).interactive())
            .disabled(viewModel.isGenerating)
            .accessibilityIdentifier("generateButton")
            .accessibilityHint("Creates a QR code from the current input text using the selected error correction level.")
            .accessibilityLabel(viewModel.isGenerating ? "Generating QR code" : "Generate QR code")

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .accessibilityLabel("Generation error: \(error)")
            }
        }
    }

    // MARK: Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                if let pasted = UIPasteboard.general.string, !pasted.isEmpty {
                    viewModel.inputText = pasted
                }
            } label: {
                Label("Paste", systemImage: "doc.on.clipboard")
            }
            .accessibilityIdentifier("toolbarPasteButton")
            .accessibilityHint("Pastes clipboard content into the input field.")

            if !viewModel.inputText.isEmpty {
                Button {
                    viewModel.inputText = ""
                } label: {
                    Label("Clear", systemImage: "xmark.circle")
                }
                .accessibilityIdentifier("toolbarClearButton")
                .accessibilityHint("Clears the input text.")
            }

            if let image = viewModel.renderedImage {
                ShareLink(item: Image(uiImage: image),
                          preview: SharePreview("QR Code", image: Image(uiImage: image))) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Share QR code")
                .accessibilityHint("Opens share sheet to send the generated QR code.")
            }
        }
    }

    // MARK: Presentation-only side effects

    private func respond(to phase: QRGeneratorViewModel.Phase) {
        switch phase {
        case .generating:
            UIAccessibility.post(notification: .announcement, argument: "Generating QR code…")
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            UIAccessibility.post(notification: .announcement, argument: "QR code generated successfully.")
        case let .failure(message):
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            UIAccessibility.post(notification: .announcement, argument: "Error: \(message)")
        case .idle:
            break
        }
    }
}

// MARK: Preview

#Preview("Dark Mode") {
    ContentView(viewModel: PreviewFactory.viewModel())
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    ContentView(viewModel: PreviewFactory.viewModel())
        .preferredColorScheme(.light)
}
