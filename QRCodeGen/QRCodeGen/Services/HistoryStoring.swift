//
//  HistoryStoring.swift
//  QRCodeGen
//
//  Persistence seam for generation history. Keeping this protocol in front of
//  SwiftData lets the view model stay storage-agnostic and lets tests run
//  against an in-memory container (or a pure mock).
//

import Foundation

@MainActor
protocol HistoryStoring {
    func recentEntries(limit: Int) throws -> [QRHistoryEntry]
    func add(_ request: QRCodeRequest, createdAt: Date) throws
    func delete(_ entry: QRHistoryEntry) throws
    func clear() throws
}
