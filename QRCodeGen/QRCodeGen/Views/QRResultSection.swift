//
// QRResultSection.swift
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

struct QRResultSection: View {
    let viewModel: QRGeneratorViewModel

    var body: some View {
        if let image = viewModel.displayImage {
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
                    .accessibilityLabel("Generated QR code")
                    .accessibilityHint("Double-tap and hold to open actions: copy, save, or share.")
                    .contextMenu {
                        Button {
                            viewModel.copyImage()
                        } label: {
                            Label("Copy Image", systemImage: "doc.on.doc")
                        }
                        .accessibilityIdentifier("contextCopyImage")
                        .accessibilityHint("Copies the QR code image to the clipboard.")

                        Button {
                            Task { await viewModel.saveToPhotos() }
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                        .accessibilityIdentifier("contextSaveToPhotos")
                        .accessibilityHint("Saves the QR code to your photo library.")

                        ShareLink(item: image, preview: SharePreview("QR Code", image: image)) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .accessibilityIdentifier("contextShare")
                        .accessibilityHint("Opens the share sheet to send the QR code.")
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
}

// MARK: Previews
#Preview("Light Mode") {
    List {
        QRResultSection(viewModel: PreviewFactory.populatedViewModel())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    List {
        QRResultSection(viewModel: PreviewFactory.populatedViewModel())
    }
    .preferredColorScheme(.dark)
}
