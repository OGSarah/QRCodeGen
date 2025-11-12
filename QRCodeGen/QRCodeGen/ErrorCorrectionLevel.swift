//
//  ErrorCorrectionLevel.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//

enum ErrorCorrectionLevel: UInt8, CaseIterable, Identifiable {
    case L = 0b01   // Low   ~7%
    case M = 0b00   // Medium ~15%
    case Q = 0b11   // Quartile ~25%
    case H = 0b10   // High   ~30%

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
