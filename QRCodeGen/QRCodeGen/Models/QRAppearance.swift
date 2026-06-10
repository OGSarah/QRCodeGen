//
//  QRAppearance.swift
//  QRCodeGen
//
//  Value type describing the visual styling of a generated QR code:
//  foreground/background tint and module size. `Codable` (via hex strings)
//  so it can be persisted alongside a history entry, and `Sendable` so it
//  can cross actor boundaries into the off-main generator.
//

import SwiftUI

nonisolated struct QRAppearance: Sendable, Equatable, Codable {
    var foreground: Color
    var background: Color
    /// Pixels per QR module. Clamped to a sensible, scannable range.
    var modulePixelSize: Int

    static let `default` = QRAppearance(foreground: .black, background: .white, modulePixelSize: 10)

    /// Allowed module sizes. Below ~6px QR codes get hard to scan on screen;
    /// above ~20px they waste space without improving scannability.
    static let moduleSizeRange: ClosedRange<Int> = 6...20

    init(foreground: Color, background: Color, modulePixelSize: Int) {
        self.foreground = foreground
        self.background = background
        self.modulePixelSize = modulePixelSize.clamped(to: Self.moduleSizeRange)
    }

    // MARK: Codable (persist Color as hex)

    private enum CodingKeys: String, CodingKey {
        case foreground, background, modulePixelSize
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let foregroundHex = try container.decode(String.self, forKey: .foreground)
        let backgroundHex = try container.decode(String.self, forKey: .background)
        self.init(
            foreground: Color(hex: foregroundHex) ?? .black,
            background: Color(hex: backgroundHex) ?? .white,
            modulePixelSize: try container.decode(Int.self, forKey: .modulePixelSize)
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(foreground.hexString, forKey: .foreground)
        try container.encode(background.hexString, forKey: .background)
        try container.encode(modulePixelSize, forKey: .modulePixelSize)
    }
}

private nonisolated extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
