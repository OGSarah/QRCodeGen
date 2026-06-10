//
// CoreImageQRCodeGeneratorTests.swift
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
import SwiftUI
import Testing

@Suite("CoreImageQRCodeGenerator")
struct CoreImageQRCodeGeneratorTests {
    private let generator = CoreImageQRCodeGenerator()

    /// Normalizes to a known pixel format for deterministic comparison.
    private func pixelData(_ image: CGImage) -> Data? {
        let width = image.width
        let height = image.height
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        ) else {
            return nil
        }

        context.interpolationQuality = .none
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let data = context.data else { return nil }
        return Data(bytes: data, count: bytesPerRow * height)
    }

    private func request(
        _ text: String,
        _ level: ErrorCorrectionLevel = .M,
        appearance: QRAppearance = .default
    ) -> QRCodeRequest {
        QRCodeRequest(text: text, errorCorrectionLevel: level, appearance: appearance)
    }

    @Test("Generates a QR image for simple input at all ECLs")
    func generatesImageForAllECLs() async throws {
        for level in ErrorCorrectionLevel.allCases {
            let image = try await generator.makeImage(for: request("Hello, QR!", level))
            #expect(image.width > 0 && image.height > 0)
        }
    }

    @Test("Deterministic output for same input and ECL")
    func deterministicOutput() async throws {
        let request = request("Deterministic test 123")
        let first = try await generator.makeImage(for: request)
        let second = try await generator.makeImage(for: request)

        let a = try #require(pixelData(first))
        let b = try #require(pixelData(second))
        #expect(a == b)
    }

    @Test("Different ECLs usually produce different pixel data")
    func differentECLProducesDifferentImage() async throws {
        let text = "A payload long enough to influence error correction structure 1234567890"
        let low = try await generator.makeImage(for: request(text, .L))
        let high = try await generator.makeImage(for: request(text, .H))

        let dataLow = try #require(pixelData(low))
        let dataHigh = try #require(pixelData(high))
        #expect(dataLow != dataHigh)
    }

    @Test("Handles empty input without throwing")
    func emptyInput() async throws {
        let image = try await generator.makeImage(for: request(""))
        #expect(image.width > 0 && image.height > 0)
    }

    @Test("Larger module size yields a larger image")
    func moduleSizeScalesOutput() async throws {
        let small = try await generator.makeImage(
            for: request("Size", appearance: QRAppearance(foreground: .black, background: .white, modulePixelSize: 6))
        )
        let large = try await generator.makeImage(
            for: request("Size", appearance: QRAppearance(foreground: .black, background: .white, modulePixelSize: 12))
        )
        #expect(large.width > small.width)
    }

    @Test("Foreground tint changes the rendered pixels")
    func tintChangesPixels() async throws {
        let blackOnWhite = try await generator.makeImage(for: request("Tint"))
        let redOnWhite = try await generator.makeImage(
            for: request("Tint", appearance: QRAppearance(foreground: .red, background: .white, modulePixelSize: 10))
        )
        let plain = try #require(pixelData(blackOnWhite))
        let tinted = try #require(pixelData(redOnWhite))
        #expect(plain != tinted)
    }
}
