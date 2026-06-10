//
//  ImageExporting.swift
//  QRCodeGen
//
//  Abstracts the system side effects of exporting a rendered QR image
//  (clipboard, photo library) so the view model can be tested without
//  touching UIKit or the user's photo library.
//

import UIKit

@MainActor
protocol ImageExporting {
    func copyToPasteboard(_ image: UIImage)
    func saveToPhotos(_ image: UIImage) async throws
}
