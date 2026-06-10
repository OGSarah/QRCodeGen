//
//  QRCodeRequest.swift
//  QRCodeGen
//
//  Immutable bundle of everything needed to render one QR code. Passing a
//  single `Sendable` value (instead of loose parameters) keeps the generator
//  protocol stable as new options are added and makes it trivial to persist
//  the inputs that produced a history entry.
//

nonisolated struct QRCodeRequest: Sendable, Equatable {
    var text: String
    var errorCorrectionLevel: ErrorCorrectionLevel
    var appearance: QRAppearance

    init(text: String, errorCorrectionLevel: ErrorCorrectionLevel, appearance: QRAppearance = .default) {
        self.text = text
        self.errorCorrectionLevel = errorCorrectionLevel
        self.appearance = appearance
    }
}
