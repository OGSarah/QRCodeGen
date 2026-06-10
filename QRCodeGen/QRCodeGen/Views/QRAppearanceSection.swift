//
//  QRAppearanceSection.swift
//  QRCodeGen
//
//  Customization controls: foreground/background tint and module size. Edits
//  live-restyle an already-generated code via the view model's debounced
//  regeneration.
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
        } header: {
            Label("Appearance", systemImage: "paintpalette")
                .accessibilityAddTraits(.isHeader)
        } footer: {
            Text("Customize the colors and size of the generated QR code. High contrast keeps it scannable.")
                .font(.footnote)
        }
        .onChange(of: viewModel.appearance) {
            viewModel.regenerateIfNeeded()
        }
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
