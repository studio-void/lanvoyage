//
//  ChatHistoryView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import Foundation

enum ChatHistoryStore {
    private static var _items: [ChatSummary] = []
    private static var _fullTextByID: [String: String] = [:]
    private static var _durationByID: [String: Int] = [:]
    private static var _scoreByID: [String: Int] = [:]
    private static var _scoreReasonByID: [String: String] = [:]

    // MARK: - Create

    static func append(_ summary: ChatSummary) {
        _items.insert(summary, at: 0)
    }

    static func append(summary: ChatSummary, fullText: String) {
        _items.insert(summary, at: 0)
        _fullTextByID[summary.id] = fullText
    }

    // MARK: - Read

    static func all() -> [ChatSummary] {
        _items
    }

    static func fullText(for id: String) -> String? {
        _fullTextByID[id]
    }

    static func duration(for id: String) -> Int? {
        _durationByID[id]
    }

    static func score(for id: String) -> Int? {
        _scoreByID[id]
    }

    static func scoreReason(for id: String) -> String? {
        _scoreReasonByID[id]
    }

    // MARK: - Update (metadata)

    static func setDuration(for id: String, seconds: Int) {
        _durationByID[id] = seconds
    }

    static func setScore(for id: String, score: Int, reason: String?) {
        _scoreByID[id] = score
        if let r = reason { _scoreReasonByID[id] = r }
    }

    // MARK: - Delete

    static func remove(atOffsets offsets: IndexSet) {
        for i in offsets.sorted(by: >) {
            guard _items.indices.contains(i) else { continue }
            let id = _items[i].id
            _items.remove(at: i)
            _fullTextByID[id] = nil
            _durationByID[id] = nil
            _scoreByID[id] = nil
            _scoreReasonByID[id] = nil
        }
    }

    static func clear() {
        _items.removeAll()
        _fullTextByID.removeAll()
        _durationByID.removeAll()
        _scoreByID.removeAll()
        _scoreReasonByID.removeAll()
    }
}
