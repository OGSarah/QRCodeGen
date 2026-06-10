//
//  QRResultSection.swift
//  QRCodeGen
//
//  Displays the generated QR code and its copy / save / share actions.
//  Rendered only when a code exists.
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
