//
// QRAppearance.swift
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

nonisolated struct QRAppearance: Sendable, Equatable, Codable {
    var foreground: Color
    var background: Color
    /// Pixels per QR module. Clamped to a sensible, scannable range.
    var modulePixelSize: Int

    static let `default` = Self(foreground: .black, background: .white, modulePixelSize: 10)

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
