//
// QRHistoryEntry.swift
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
