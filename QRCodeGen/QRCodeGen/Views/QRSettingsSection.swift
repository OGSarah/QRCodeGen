//
//  QRSettingsSection.swift
//  QRCodeGen
//
//  Error-correction level selection. Changing the level live-regenerates an
//  existing QR code (debounced) so the effect is visible immediately.
//

import SwiftUI

struct QRSettingsSection: View {
    @Bindable var viewModel: QRGeneratorViewModel

    var body: some View {
        Section {
            Picker("Level", selection: $viewModel.errorCorrectionLevel) {
                ForEach(ErrorCorrectionLevel.allCases) { level in
                    Text(level.description)
                        .tag(level)
                        .accessibilityIdentifier("eclSegment_\(level.ciLevel)")
                        .accessibilityLabel(level.description)
                }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("eclSegmentedControl")
            .accessibilityLabel("Error Correction Level")
            .accessibilityHint("Choose how resilient the QR code should be to damage. Higher levels use more space but are more resilient.")
            .onChange(of: viewModel.errorCorrectionLevel) {
                viewModel.regenerateIfNeeded()
            }
        } header: {
            Label("Error Correction Level", systemImage: "gauge.with.needle")
                .accessibilityAddTraits(.isHeader)
        } footer: {
            Text("Higher levels make the QR code more resilient to damage.")
                .font(.footnote)
                .accessibilityLabel("Higher error correction levels increase reliability but make the QR code denser.")
        }
    }
}
