//
// QRInputSection.swift
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

import SwiftUI

struct QRInputSection: View {
    @Bindable var viewModel: QRGeneratorViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        Section {
            TextField("Enter text to encode", text: $viewModel.inputText, axis: .vertical)
                .textInputAutocapitalization(.never)
                .lineLimit(5)
                .submitLabel(.done)
                .focused($isInputFocused)
                .toolbar {
                    // A vertical-axis TextField inserts a newline on the keyboard's
                    // return key, so it never fires `onSubmit`. Provide an explicit
                    // Done button above the keyboard to dismiss it.
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            isInputFocused = false
                        }
                        .accessibilityIdentifier("keyboardDoneButton")
                        .accessibilityHint("Dismisses the keyboard.")
                    }
                }
                .accessibilityIdentifier("inputTextField")
                .accessibilityLabel("QR code input text")
                .accessibilityHint(
                    "Enter the text or URL you want to encode into a QR code. Supports multi-line input."
                )
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
