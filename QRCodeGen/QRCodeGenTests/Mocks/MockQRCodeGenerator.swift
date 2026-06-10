//
//  MockQRCodeGenerator.swift
//  QRCodeGenTests
//
//  Deterministic `QRCodeGenerating` test double: returns a tiny image on
//  success, or throws a configured error.
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
                data: nil, width: 1, height: 1,
                bitsPerComponent: 8, bytesPerRow: 1,
                space: space, bitmapInfo: CGImageAlphaInfo.none.rawValue
            ),
            let image = context.makeImage()
        else {
            fatalError("Unable to create test pixel image")
        }
        return image
    }
}
