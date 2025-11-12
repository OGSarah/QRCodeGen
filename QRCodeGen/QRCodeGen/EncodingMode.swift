//
//  EncodingMode.swift
//  QRCodeGen
//
//  Created by Sarah Clark on 11/11/25.
//

import Foundation

enum EncodingMode: UInt8 {
    case numeric = 0b0001
    case alphanumeric = 0b0010
    case byte = 0b0100
    case kanji = 0b1000

    var indicator: UInt8 { rawValue }

    static func detect(from text: String) -> EncodingMode {
        let numericChars = CharacterSet(charactersIn: "0123456789")
        let alphanumChars = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ $%*+-./:")

        let chars = text.unicodeScalars
        if chars.allSatisfy({ numericChars.contains($0) }) {
            return .numeric
        } else if chars.allSatisfy({ alphanumChars.contains($0) }) {
            return .alphanumeric
        } else {
            return .byte
        }
    }

}
