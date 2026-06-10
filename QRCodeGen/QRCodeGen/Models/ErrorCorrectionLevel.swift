//
// ErrorCorrectionLevel.swift
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

nonisolated enum ErrorCorrectionLevel: UInt8, CaseIterable, Identifiable, Sendable {
    // L/M/Q/H are the standard QR error-correction level codes (they map directly
    // to CoreImage's single-character level), so the short names are intentional.
    // swiftlint:disable identifier_name
    case L = 0b01   // Low   ~7%
    case M = 0b00   // Medium ~15%
    case Q = 0b11   // Quartile ~25%
    case H = 0b10   // High   ~30%
    // swiftlint:enable identifier_name

    var id: Self { self }

    var description: String {
        switch self {
        case .L: return "Low"
        case .M: return "Medium"
        case .Q: return "Quartile"
        case .H: return "High"
        }
    }

    // CoreImage uses a single-character string
    var ciLevel: String {
        switch self {
        case .L: return "L"
        case .M: return "M"
        case .Q: return "Q"
        case .H: return "H"
        }
    }
}
