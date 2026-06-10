//
// QRCodeError.swift
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
