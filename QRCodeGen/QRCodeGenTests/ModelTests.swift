//
// ModelTests.swift
// QRCodeGenTests
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

@testable import QRCodeGen
import SwiftUI
import Testing

@Suite("Models")
struct ModelTests {
    @Test("Module size is clamped to the supported range")
    func moduleSizeClamped() {
        let tooLarge = QRAppearance(foreground: .black, background: .white, modulePixelSize: 999)
        let tooSmall = QRAppearance(foreground: .black, background: .white, modulePixelSize: 0)
        #expect(tooLarge.modulePixelSize == QRAppearance.moduleSizeRange.upperBound)
        #expect(tooSmall.modulePixelSize == QRAppearance.moduleSizeRange.lowerBound)
    }

    @Test("Appearance round-trips through Codable")
    func appearanceCodableRoundTrip() throws {
        let foreground = try #require(Color(hex: "#112233"))
        let original = QRAppearance(foreground: foreground, background: .white, modulePixelSize: 8)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(QRAppearance.self, from: data)

        #expect(decoded.modulePixelSize == 8)
        #expect(decoded.foreground.hexString == "#112233")
    }

    @Test("Color hex parsing accepts valid and rejects malformed strings")
    func colorHexParsing() throws {
        let parsed = try #require(Color(hex: "FF8800"))
        #expect(parsed.hexString == "#FF8800")
        #expect(Color(hex: "nope") == nil)
        #expect(Color(hex: "#12") == nil)
    }

    @Test("Error correction levels map to single-character CI codes")
    func ciLevelMapping() {
        #expect(ErrorCorrectionLevel.L.ciLevel == "L")
        #expect(ErrorCorrectionLevel.H.ciLevel == "H")
    }
}
