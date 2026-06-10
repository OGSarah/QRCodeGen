//
//  QRInputSection.swift
//  QRCodeGen
//
//  Text entry for the payload to encode, with inline clear and paste actions.
//

import SwiftUI

struct QRInputSection: View {
    @Bindable var viewModel: QRGeneratorViewModel

    var body: some View {
        Section {
            TextField("Enter text to encode", text: $viewModel.inputText, axis: .vertical)
                .textInputAutocapitalization(.never)
                .lineLimit(5)
                .submitLabel(.done)
                .accessibilityIdentifier("inputTextField")
                .accessibilityLabel("QR code input text")
                .accessibilityHint("Enter the text or URL you want to encode into a QR code. Supports multi-line input.")
                .overlay(alignment: .trailing) {
                    HStack(spacing: 8) {
                        if !viewModel.inputText.isEmpty {
                            Button {
                                viewModel.inputText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Clear input")
                            .accessibilityHint("Removes all text from the input field.")
                        }
                        Button {
                            if let pasted = UIPasteboard.general.string, !pasted.isEmpty {
                                viewModel.inputText = pasted
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
    }
}

// MARK: Previews
#Preview("Light Mode") {
    List {
        QRInputSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    List {
        QRInputSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.dark)
}
