//
//  Color+Hex.swift
//  QRCodeGen
//
//  Lightweight hex <-> Color bridging. `Color` is not directly `Codable`,
//  so appearance options are persisted as `#RRGGBB` strings. Kept small and
//  dependency-free on purpose.
//

import SwiftUI

nonisolated extension Color {
    /// Creates a color from a `#RRGGBB` (or `RRGGBB`) string. Returns nil for malformed input.
    init?(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") { value.removeFirst() }
        guard value.count == 6, let int = UInt32(value, radix: 16) else { return nil }

        let red = Double((int >> 16) & 0xFF) / 255
        let green = Double((int >> 8) & 0xFF) / 255
        let blue = Double(int & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }

    /// Returns a `#RRGGBB` representation using the resolved sRGB components.
    var hexString: String {
        let resolved = UIColor(self).cgColor.converted(
            to: CGColorSpace(name: CGColorSpace.sRGB)!,
            intent: .defaultIntent,
            options: nil
        )
        let components = resolved?.components ?? [0, 0, 0, 1]
        func channel(_ index: Int) -> Int {
            let value = components.count > index ? components[index] : 0
            return Int((value * 255).rounded())
        }
        return String(format: "#%02X%02X%02X", channel(0), channel(1), channel(2))
    }
}
