//
//  QRHistoryDetailView.swift
//  QRCodeGen
//
//  Detail screen pushed when a history entry is tapped. Re-renders the saved
//  entry's QR code from its stored request and shows the inputs that produced
//  it. Offers to share the rendered code from the toolbar.
//

import SwiftUI

struct QRHistoryDetailView: View {
    let entry: QRHistoryEntry
    let viewModel: QRGeneratorViewModel

    @Environment(\.dismiss) private var dismiss

    /// Re-rendered preview of the saved entry, independent of the editor.
    @State private var image: UIImage?
    @State private var renderError: String?

    var body: some View {
        List {
            previewSection
            informationSection
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("QR Code Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let image {
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: Image(uiImage: image),
                              preview: SharePreview("QR Code", image: Image(uiImage: image))) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share QR code")
                    .accessibilityHint("Opens the share sheet to send this QR code.")
                }
            }
        }
        .task { await render() }
    }

    // MARK: Preview

    @ViewBuilder
    private var previewSection: some View {
        Section {
            if let image {
                Image(uiImage: image)
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
                    .accessibilityIdentifier("historyDetailImageView")
                    .accessibilityLabel("QR code for \(entry.text)")
            } else if let renderError {
                Text(renderError)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .accessibilityLabel("Could not render QR code: \(renderError)")
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .accessibilityLabel("Rendering QR code")
            }
        } header: {
            Label("QR Code", systemImage: "qrcode.viewfinder")
                .accessibilityAddTraits(.isHeader)
        }
    }

    // MARK: Information

    private var informationSection: some View {
        Section {
            infoRow(label: "Content", value: entry.text)
            infoRow(label: "Error Correction", value: entry.errorCorrectionLevel.description)
            infoRow(label: "Module Size", value: "\(entry.appearance.modulePixelSize) px")
            infoRow(label: "Created", value: entry.createdAt.formatted(date: .abbreviated, time: .shortened))
            colorRow(label: "Foreground", color: entry.appearance.foreground)
            colorRow(label: "Background", color: entry.appearance.background)
        } header: {
            Label("Information", systemImage: "info.circle")
                .accessibilityAddTraits(.isHeader)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }

    private func colorRow(label: String, color: Color) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(.quaternary, lineWidth: 1)
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) color")
    }

    // MARK: Rendering

    private func render() async {
        do {
            image = try await viewModel.image(for: entry.request)
            renderError = nil
        } catch {
            image = nil
            renderError = (error as? QRCodeError)?.errorDescription ?? error.localizedDescription
        }
    }
}

// MARK: Previews
#Preview("Light Mode") {
    NavigationStack {
        QRHistoryDetailView(entry: PreviewFactory.sampleEntry(), viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        QRHistoryDetailView(entry: PreviewFactory.sampleEntry(), viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.dark)
}
