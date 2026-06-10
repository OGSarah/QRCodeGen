//
//  QRHistorySection.swift
//  QRCodeGen
//
//  Recent generations, persisted via SwiftData. Tapping an entry restores its
//  inputs into the editor and regenerates; swipe to delete.
//

import SwiftUI

struct QRHistorySection: View {
    let viewModel: QRGeneratorViewModel

    var body: some View {
        if !viewModel.history.isEmpty {
            Section {
                ForEach(viewModel.history) { entry in
                    Button {
                        viewModel.restore(entry)
                    } label: {
                        row(for: entry)
                    }
                    .accessibilityIdentifier("historyEntry")
                    .accessibilityLabel("History entry: \(entry.text)")
                    .accessibilityHint("Restores this text and settings, then regenerates.")
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
