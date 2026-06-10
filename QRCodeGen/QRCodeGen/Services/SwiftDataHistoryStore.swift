//
//  SwiftDataHistoryStore.swift
//  QRCodeGen
//
//  Live `HistoryStoring` implementation backed by SwiftData. SwiftData is an
//  implementation detail here, not the architecture: nothing outside this
//  file imports it.
//

import Foundation
import SwiftData

@MainActor
struct SwiftDataHistoryStore: HistoryStoring {
    let context: ModelContext

    func recentEntries(limit: Int) throws -> [QRHistoryEntry] {
        var descriptor = FetchDescriptor<QRHistoryEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try context.fetch(descriptor)
    }

    func add(_ request: QRCodeRequest, createdAt: Date) throws {
        context.insert(QRHistoryEntry(request: request, createdAt: createdAt))
        try context.save()
    }

    func delete(_ entry: QRHistoryEntry) throws {
        context.delete(entry)
        try context.save()
    }

    func clear() throws {
        try context.delete(model: QRHistoryEntry.self)
        try context.save()
    }
}
