//
//  MockHistoryStore.swift
//  QRCodeGenTests
//
//  In-memory `HistoryStoring` test double — no SwiftData involved.
//

import Foundation
@testable import QRCodeGen

@MainActor
final class MockHistoryStore: HistoryStoring {
    private(set) var entries: [QRHistoryEntry] = []

    func recentEntries(limit: Int) throws -> [QRHistoryEntry] {
        Array(entries.prefix(limit))
    }

    func add(_ request: QRCodeRequest, createdAt: Date) throws {
        entries.insert(QRHistoryEntry(request: request, createdAt: createdAt), at: 0)
    }

    func delete(_ entry: QRHistoryEntry) throws {
        entries.removeAll { $0 === entry }
    }

    func clear() throws {
        entries.removeAll()
    }
}
