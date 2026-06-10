//
//  QRCodeError.swift
//  QRCodeGen
//
//  A typed, user-presentable error for every failure path in the
//  generation and export pipeline. Replaces the previous untyped
//  `NSError(domain:code:)` throws so call sites can switch on the case
//  and tests can assert exact failures via `Equatable`.
//

import Foundation

nonisolated enum QRCodeError: LocalizedError, Equatable {
    /// Core Image could not build a QR code from the supplied message.
    case generationFailed
    /// The generated `CIImage` could not be rasterized to a `CGImage`.
    case renderingFailed
    /// The user did not grant (add-only) access to the photo library.
    case photoLibraryAccessDenied
    /// Writing the QR code to the photo library failed.
    case saveFailed

    var errorDescription: String? {
        switch self {
        case .generationFailed:
            return "Couldn't build a QR code from this input."
        case .renderingFailed:
            return "Couldn't render the QR image."
        case .photoLibraryAccessDenied:
            return "Photo library access is required to save the QR code. Enable it in Settings."
        case .saveFailed:
            return "Couldn't save the QR code to your photo library."
        }
    }
}
