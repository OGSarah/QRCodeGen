//
//  MockImageExporter.swift
//  QRCodeGenTests
//
//  Records export calls and can be configured to fail saving.
//

import UIKit
@testable import QRCodeGen

@MainActor
final class MockImageExporter: ImageExporting {
    private(set) var copiedImages: [UIImage] = []
    private(set) var savedImages: [UIImage] = []
    var saveError: QRCodeError?

    func copyToPasteboard(_ image: UIImage) {
        copiedImages.append(image)
    }

    func saveToPhotos(_ image: UIImage) async throws {
        if let saveError { throw saveError }
        savedImages.append(image)
    }
}
