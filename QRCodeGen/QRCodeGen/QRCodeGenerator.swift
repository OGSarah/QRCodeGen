//
//  QRCodeGenerator.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//

import CoreImage
import Foundation

class QRCodeGenerator {

    func generateQRCode(
        from text: String,
        errorCorrectionLevel ecl: ErrorCorrectionLevel,
        version: Int = 4
    ) throws -> CGImage {

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            throw NSError(domain: "QRCodeGenerator", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "CIQRCodeGenerator not available"])
        }

        // CoreImage expects UTF-8 bytes
        let data = text.data(using: .utf8) ?? Data()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue(ecl.ciLevel, forKey: "inputCorrectionLevel")

        guard let ciImage = filter.outputImage else {
            throw NSError(domain: "QRCodeGenerator", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to produce CIImage"])
        }

        // Choose a reasonable module size (10 px per module + 4-module quiet zone)
        let modulePixelSize = 10
        let quietZoneModules = 4
        let transform = CGAffineTransform(scaleX: CGFloat(modulePixelSize),
                                          y: CGFloat(modulePixelSize))
        let scaled = ciImage.transformed(by: transform)

        // Add quiet zone (white padding) – CoreImage does **not** add it automatically
        _ = scaled.extent.size
        let padded = scaled.transformed(by: CGAffineTransform(
            translationX: CGFloat(quietZoneModules * modulePixelSize),
            y: CGFloat(quietZoneModules * modulePixelSize)
        ))

        let context = CIContext(options: [.useSoftwareRenderer: false])
        guard let cgImage = context.createCGImage(padded, from: padded.extent) else {
            throw NSError(domain: "QRCodeGenerator", code: 3,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to create CGImage"])
        }

        return cgImage
    }
}
