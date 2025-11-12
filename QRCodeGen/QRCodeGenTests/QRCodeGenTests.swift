//
//  QRCodeGenTests.swift
//  QRCodeGenTests
//
//  Created by Sarah Clark on 11/11/25.
//

import CoreGraphics
import CoreImage
import Testing
@testable import QRCodeGen

@Suite("QRCodeGenerator tests")
struct QRCodeGeneratorTests {

    private func imagePixelData(_ image: CGImage) -> Data? {
        // Normalize to a known pixel format for deterministic comparison
        let width = image.width
        let height = image.height
        let bitsPerComponent = 8
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
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

    @Test("Generates a QR image for simple input at all ECLs")
    func generatesImageForAllECLs() throws {
        let generator = QRCodeGenerator()
        for level in ErrorCorrectionLevel.allCases {
            let cg = try generator.generateQRCode(from: "Hello, QR!", errorCorrectionLevel: level, version: 4)
            #expect(cg.width > 0 && cg.height > 0, "Image should have non-zero dimensions")
        }
    }

    @Test("Deterministic output for same input and ECL")
    func deterministicOutput() throws {
        let generator = QRCodeGenerator()
        let text = "Deterministic test 123"
        let ecl: ErrorCorrectionLevel = .M

        let img1 = try generator.generateQRCode(from: text, errorCorrectionLevel: ecl, version: 4)
        let img2 = try generator.generateQRCode(from: text, errorCorrectionLevel: ecl, version: 4)

        let d1 = imagePixelData(img1)
        let d2 = imagePixelData(img2)

        let a = try #require(d1)
        let b = try #require(d2)

        #expect(a == b, "Same input and ECL should yield identical pixel data")
    }

    @Test("Different ECLs usually produce different pixel data")
    func differentECLProducesDifferentImage() throws {
        let generator = QRCodeGenerator()
        let text = "This is a payload long enough to influence error correction structure 1234567890"

        let imgL = try generator.generateQRCode(from: text, errorCorrectionLevel: .L, version: 4)
        let imgH = try generator.generateQRCode(from: text, errorCorrectionLevel: .H, version: 4)

        let dL = try #require(imagePixelData(imgL))
        let dH = try #require(imagePixelData(imgH))

        // This is a probabilistic expectation; if it ever fails in CI, consider relaxing to a warning.
        #expect(dL != dH, "Different ECLs should typically produce different encoded images for non-trivial input")
    }

    @Test("Handles empty input without crashing")
    func emptyInput() throws {
        let generator = QRCodeGenerator()
        let img = try generator.generateQRCode(from: "", errorCorrectionLevel: .M, version: 4)
        #expect(img.width > 0 && img.height > 0)
    }
}
