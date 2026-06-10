//
// HistoryStoreTests.swift
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

import Foundation
@testable import QRCodeGen
import SwiftData
import SwiftUI
import Testing

@MainActor
@Suite("SwiftDataHistoryStore", .serialized)
struct HistoryStoreTests {
    /// Each test gets a fresh container in a unique temp-directory file. The
    /// test host's sandbox lacks an Application Support directory, so the
    /// default (and even in-memory) store location is unavailable there;
    /// `NSTemporaryDirectory()` is always present and writable.
    private func makeStore() throws -> SwiftDataHistoryStore {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appending(path: "history-\(UUID().uuidString).store")
        let container = try ModelContainer(
            for: QRHistoryEntry.self,
            configurations: ModelConfiguration(url: url)
        )
        return SwiftDataHistoryStore(context: ModelContext(container))
    }

    private func request(_ text: String, _ level: ErrorCorrectionLevel = .M) -> QRCodeRequest {
        QRCodeRequest(text: text, errorCorrectionLevel: level)
    }

    @Test("Adds and fetches an entry")
    func addAndFetch() throws {
        let store = try makeStore()
        try store.add(request("Alpha"), createdAt: Date(timeIntervalSince1970: 1))

        let entries = try store.recentEntries(limit: 10)
        #expect(entries.count == 1)
        #expect(entries.first?.text == "Alpha")
    }

    @Test("Recent entries are returned newest first")
    func newestFirstOrdering() throws {
        let store = try makeStore()
        try store.add(request("Older"), createdAt: Date(timeIntervalSince1970: 100))
        try store.add(request("Newer"), createdAt: Date(timeIntervalSince1970: 200))

        let entries = try store.recentEntries(limit: 10)
        #expect(entries.map(\.text) == ["Newer", "Older"])
    }

    @Test("Fetch limit is respected")
    func fetchLimitRespected() throws {
        let store = try makeStore()
        for index in 0..<5 {
            try store.add(request("Entry \(index)"), createdAt: Date(timeIntervalSince1970: Double(index)))
        }
        #expect(try store.recentEntries(limit: 3).count == 3)
    }

    @Test("Delete removes the entry")
    func deleteRemovesEntry() throws {
        let store = try makeStore()
        try store.add(request("Doomed"), createdAt: Date(timeIntervalSince1970: 1))
        let entry = try #require(try store.recentEntries(limit: 1).first)

        try store.delete(entry)
        #expect(try store.recentEntries(limit: 10).isEmpty)
    }

    @Test("Clear removes everything")
    func clearRemovesAll() throws {
        let store = try makeStore()
        try store.add(request("One"), createdAt: Date(timeIntervalSince1970: 1))
        try store.add(request("Two"), createdAt: Date(timeIntervalSince1970: 2))

        try store.clear()
        #expect(try store.recentEntries(limit: 10).isEmpty)
    }

    @Test("Round-trips the appearance and error-correction level")
    func roundTripsRequestDetails() throws {
        let store = try makeStore()
        let appearance = QRAppearance(foreground: .red, background: .white, modulePixelSize: 8)
        try store.add(
            QRCodeRequest(text: "Styled", errorCorrectionLevel: .Q, appearance: appearance),
            createdAt: Date(timeIntervalSince1970: 1)
        )

        let entry = try #require(try store.recentEntries(limit: 1).first)
        #expect(entry.errorCorrectionLevel == .Q)
        #expect(entry.appearance.modulePixelSize == 8)
    }
}
