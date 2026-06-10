//
//  CoreImageQRCodeGenerator.swift
//  QRCodeGen
//
//  Live `QRCodeGenerating` implementation backed by Core Image's
//  `CIQRCodeGenerator` filter. Replaces the previous `QRCodeGenerator` class:
//  typed errors instead of NSError, named constants instead of magic numbers,
//  a correct quiet zone, and configurable foreground/background tint.
//

import CoreImage
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
