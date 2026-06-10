//
// QRAppearanceSection.swift
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

struct QRAppearanceSection: View {
    @Bindable var viewModel: QRGeneratorViewModel

    var body: some View {
        Section {
            ColorPicker("Foreground", selection: $viewModel.appearance.foreground, supportsOpacity: false)
                .accessibilityIdentifier("appearanceForegroundColor")
                .accessibilityHint("The color of the QR code's dark modules.")

            ColorPicker("Background", selection: $viewModel.appearance.background, supportsOpacity: false)
                .accessibilityIdentifier("appearanceBackgroundColor")
                .accessibilityHint("The color behind the QR code.")

            VStack(alignment: .leading) {
                LabeledContent("Module Size", value: "\(viewModel.appearance.modulePixelSize) px")
                Slider(
                    value: moduleSizeBinding,
                    in: sliderRange,
                    step: 1
                )
                .accessibilityIdentifier("appearanceModuleSize")
                .accessibilityLabel("Module size")
                .accessibilityValue("\(viewModel.appearance.modulePixelSize) pixels per module")
            }

            LabeledContent("Preview") {
                colorPreview
            }
        } header: {
            Label("Appearance", systemImage: "paintpalette")
                .accessibilityAddTraits(.isHeader)
        } footer: {
            Text(
                "Customize the colors and size of the generated QR code. " +
                "High contrast keeps it scannable. Tap Generate to apply your changes."
            )
                .font(.footnote)
        }
    }

    /// A lightweight swatch showing the current foreground/background pairing,
    /// updated live as the colors change — without re-rendering the full code.
    private var colorPreview: some View {
        Image(systemName: "qrcode")
            .resizable()
            .interpolation(.none)
            // Decorative within the swatch: the enclosing accessibilityElement
            // below exposes the label/value, so hide the inner image. (Also
            // satisfies accessibility_label_for_image, which can't see that the
            // element provides the label.) Placed after the Image-only modifiers
            // so .resizable()/.interpolation() still type-check.
            .accessibilityHidden(true)
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundStyle(viewModel.appearance.foreground)
            .padding(6)
            .background(viewModel.appearance.background, in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.quaternary, lineWidth: 1)
            )
            .accessibilityIdentifier("appearanceColorPreview")
            .accessibilityElement()
            .accessibilityLabel("Color preview")
            .accessibilityValue("A sample showing the foreground color on the background color.")
    }

    private var sliderRange: ClosedRange<Double> {
        Double(QRAppearance.moduleSizeRange.lowerBound)...Double(QRAppearance.moduleSizeRange.upperBound)
    }

    private var moduleSizeBinding: Binding<Double> {
        Binding(
            get: { Double(viewModel.appearance.modulePixelSize) },
            set: { viewModel.appearance.modulePixelSize = Int($0) }
        )
    }
}

// MARK: Previews
#Preview("Light Mode") {
    List {
        QRAppearanceSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    List {
        QRAppearanceSection(viewModel: PreviewFactory.viewModel())
    }
    .preferredColorScheme(.dark)
}
