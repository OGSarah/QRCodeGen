//
// QRSettingsSection.swift
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
            .accessibilityHint(
                "Choose how resilient the QR code should be to damage. " +
                "Higher levels use more space but are more resilient."
            )
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

// MARK: Previews
#Preview("Light Mode") {
    List {
        QRSettingsSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    List {
        QRSettingsSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.dark)
}
