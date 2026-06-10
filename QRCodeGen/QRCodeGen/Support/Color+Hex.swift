//
// Color+Hex.swift
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
        let sRGB = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let resolved = UIColor(self).cgColor.converted(
            to: sRGB,
            intent: .defaultIntent,
            options: nil
        )
        let components = resolved?.components ?? [0, 0, 0, 1]
        func channel(_ index: Int) -> Int {
            let value = components.count > index ? components[index] : 0
            return Int((value * 255).rounded())
        }
        // Hex formatting has no clean FormatStyle equivalent; the C-style formatter is idiomatic here.
        // swiftlint:disable:next c_style_string_format
        return String(format: "#%02X%02X%02X", channel(0), channel(1), channel(2))
    }
}
