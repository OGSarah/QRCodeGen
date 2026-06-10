//
//  LiveImageExporter.swift
//  QRCodeGen
//
//  Live `ImageExporting` implementation. Unlike the previous
//  `UIImageWriteToSavedPhotosAlbum` call (fire-and-forget, swallowed
//  permission failures), saving now explicitly requests add-only photo
//  access and reports failures via typed `QRCodeError`s.
//

import Photos
import UIKit

@MainActor
struct LiveImageExporter: ImageExporting {
    func copyToPasteboard(_ image: UIImage) {
        UIPasteboard.general.image = image
    }

    func saveToPhotos(_ image: UIImage) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw QRCodeError.photoLibraryAccessDenied
        }

        do {
            try await PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        } catch {
            throw QRCodeError.saveFailed
        }
    }
}
