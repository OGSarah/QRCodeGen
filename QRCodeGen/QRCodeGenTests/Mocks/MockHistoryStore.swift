//
// MockHistoryStore.swift
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
