//
//  ModelTests.swift
//  QRCodeGenTests
//
//  Pure-logic coverage for the value types: appearance clamping/Codable and
//  the Color hex bridge.
//

import SwiftUI
import Testing
@testable import QRCodeGen

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
