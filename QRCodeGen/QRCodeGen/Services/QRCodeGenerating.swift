//
//  QRCodeGenerating.swift
//  QRCodeGen
//
//  The seam between the view model and QR rendering. Depending on this
//  protocol (rather than a concrete Core Image type) lets the view model be
//  unit-tested with a mock, and lets the rendering backend change without
//  touching call sites.
//

import CoreGraphics

nonisolated protocol QRCodeGenerating: Sendable {
    /// Renders `request` to a `CGImage`. Pure and side-effect free; safe to
    /// call off the main actor since rasterization is CPU-bound work.
    func makeImage(for request: QRCodeRequest) async throws -> CGImage
}
