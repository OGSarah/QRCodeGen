//
// QRHistorySection.swift
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

struct QRHistorySection: View {
    let viewModel: QRGeneratorViewModel

    var body: some View {
        if !viewModel.history.isEmpty {
            Section {
                ForEach(viewModel.history) { entry in
                    NavigationLink {
                        QRHistoryDetailView(entry: entry, viewModel: viewModel)
                    } label: {
                        row(for: entry)
                    }
                    .accessibilityIdentifier("historyEntry")
                    .accessibilityLabel("History entry: \(entry.text)")
                    .accessibilityHint("Opens the QR code and its details.")
                }
                .onDelete(perform: delete)
            } header: {
                Label("Recent", systemImage: "clock.arrow.circlepath")
                    .accessibilityAddTraits(.isHeader)
            }
        }
    }

    private func row(for entry: QRHistoryEntry) -> some View {
        HStack {
            Image(systemName: "qrcode")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.text)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                Text(entry.createdAt, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(entry.errorCorrectionLevel.description)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.delete(viewModel.history[index])
        }
    }
}

// MARK: Previews
#Preview("Light Mode") {
    NavigationStack {
        List {
            QRHistorySection(viewModel: PreviewFactory.populatedViewModel())
        }
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    NavigationStack {
        List {
            QRHistorySection(viewModel: PreviewFactory.populatedViewModel())
        }
    }
    .preferredColorScheme(.dark)
}
