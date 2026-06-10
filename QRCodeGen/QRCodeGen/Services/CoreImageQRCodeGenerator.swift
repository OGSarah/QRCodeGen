//
// CoreImageQRCodeGenerator.swift
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

import CoreImage.CIFilterBuiltins
import SwiftUI
import UIKit

nonisolated struct CoreImageQRCodeGenerator: QRCodeGenerating {
    /// `CIContext` is expensive to create and thread-safe, so a single
    /// instance is reused across renders.
    private let context: CIContext

    /// Quiet zone (white border) required by the QR spec, measured in modules.
    private static let quietZoneModules = 4

    init(context: CIContext = CIContext(options: [.useSoftwareRenderer: false])) {
        self.context = context
    }

    func makeImage(for request: QRCodeRequest) async throws -> CGImage {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(request.text.utf8)
        filter.correctionLevel = request.errorCorrectionLevel.ciLevel

        guard let output = filter.outputImage else {
            throw QRCodeError.generationFailed
        }

        let foreground = CIColor(color: UIColor(request.appearance.foreground))
        let background = CIColor(color: UIColor(request.appearance.background))
        let tinted = output.tinted(foreground: foreground, background: background)

        let scale = CGFloat(request.appearance.modulePixelSize)
        let scaled = tinted.transformed(by: CGAffineTransform(scaleX: scale, y: scale))

        // Composite the code over a background-colored canvas that is larger
        // than the code by `quietZoneModules` on every side.
        let quietZone = CGFloat(Self.quietZoneModules) * scale
        let canvas = scaled.extent.insetBy(dx: -quietZone, dy: -quietZone)
        let backgroundPlane = CIImage(color: background).cropped(to: canvas)
        let composited = scaled.composited(over: backgroundPlane)

        guard let cgImage = context.createCGImage(composited, from: canvas) else {
            throw QRCodeError.renderingFailed
        }
        return cgImage
    }
}

private nonisolated extension CIImage {
    /// Maps the monochrome QR output onto the requested foreground/background
    /// colors using `CIFalseColor` (color0 = dark modules, color1 = light).
    func tinted(foreground: CIColor, background: CIColor) -> CIImage {
        let filter = CIFilter.falseColor()
        filter.inputImage = self
        filter.color0 = foreground
        filter.color1 = background
        return filter.outputImage ?? self
    }
}
