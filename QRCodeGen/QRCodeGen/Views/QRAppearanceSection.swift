//
//  QRAppearanceSection.swift
//  QRCodeGen
//
//  Customization controls: foreground/background tint and module size. A small
//  swatch previews the chosen colors live; the full-size code in "Your QR Code"
//  only updates when the user taps Generate.
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
            Text("Customize the colors and size of the generated QR code. High contrast keeps it scannable. Tap Generate to apply your changes.")
                .font(.footnote)
        }
    }

    /// A lightweight swatch showing the current foreground/background pairing,
    /// updated live as the colors change — without re-rendering the full code.
    private var colorPreview: some View {
        Image(systemName: "qrcode")
            .resizable()
            .interpolation(.none)
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
