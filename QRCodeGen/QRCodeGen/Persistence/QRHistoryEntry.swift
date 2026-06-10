//
//  QRHistoryEntry.swift
//  QRCodeGen
//
//  SwiftData model for a previously generated QR code. Stores the inputs that
//  produced it (text, error-correction level, appearance) so an entry can be
//  re-rendered or restored into the editor. SwiftData is kept behind the
//  `HistoryStoring` protocol so it never leaks into the view model.
//

import Foundation
import SwiftData

@Model
final class QRHistoryEntry {
    var text: String
    /// Raw value of `ErrorCorrectionLevel`, stored as `Int` because SwiftData
    /// (CoreData) does not support `UInt8` as an attribute type.
    private var errorCorrectionRaw: Int
    var createdAt: Date
    /// JSON-encoded `QRAppearance`; optional for forward/backward compatibility.
    private var appearanceData: Data?

    init(request: QRCodeRequest, createdAt: Date) {
        self.text = request.text
        self.errorCorrectionRaw = Int(request.errorCorrectionLevel.rawValue)
        self.createdAt = createdAt
        self.appearanceData = try? JSONEncoder().encode(request.appearance)
    }

    var errorCorrectionLevel: ErrorCorrectionLevel {
        ErrorCorrectionLevel(rawValue: UInt8(errorCorrectionRaw)) ?? .M
    }

    var appearance: QRAppearance {
        guard let appearanceData,
              let decoded = try? JSONDecoder().decode(QRAppearance.self, from: appearanceData)
        else { return .default }
        return decoded
    }

    /// Rebuilds the request that produced this entry, for re-rendering or restore.
    var request: QRCodeRequest {
        QRCodeRequest(text: text, errorCorrectionLevel: errorCorrectionLevel, appearance: appearance)
    }
}
