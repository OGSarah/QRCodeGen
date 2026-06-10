//
// MockQRCodeGenerator.swift
// QRCodeGenTests
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

import CoreGraphics
@testable import QRCodeGen

nonisolated struct MockQRCodeGenerator: QRCodeGenerating {
    enum Outcome: Sendable, Equatable {
        case success
        case failure(QRCodeError)
    }

    var outcome: Outcome = .success

    func makeImage(for request: QRCodeRequest) async throws -> CGImage {
        switch outcome {
        case .success:
            return Self.makePixel()
        case let .failure(error):
            throw error
        }
    }

    static func makePixel() -> CGImage {
        let space = CGColorSpaceCreateDeviceGray()
        guard
            let context = CGContext(
                data: nil,
                width: 1,
                height: 1,
                bitsPerComponent: 8,
                bytesPerRow: 1,
                space: space,
                bitmapInfo: CGImageAlphaInfo.none.rawValue
            ),
            let image = context.makeImage()
        else {
            fatalError("Unable to create test pixel image")
        }
        return image
    }
}
