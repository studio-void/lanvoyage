//
//  ChatSummary.swift
//  lanvoyage
//
//  Created by Yeeun on 8/16/25.
//

import Foundation

struct ChatSummary: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let snippet: String
    let timestamp: Date
    let topic: String?
    let messageCount: Int
}

enum ChatStore {
    private static let key = "chat_summaries_v1"
    private static let limit = 10

    static func load() -> [ChatSummary] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([ChatSummary].self, from: data) else { return [] }
        let sorted = decoded.sorted { $0.timestamp > $1.timestamp }
        if sorted.count > limit {
            let trimmed = Array(sorted.prefix(limit))
            save(trimmed)
            return trimmed
        }
        return sorted
    }

    static func save(_ items: [ChatSummary]) {
        let sorted = items.sorted { $0.timestamp > $1.timestamp }
        let trimmed = Array(sorted.prefix(limit))
        if let data = try? JSONEncoder().encode(trimmed) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func append(_ item: ChatSummary) {
        var items = load()
        items.insert(item, at: 0)
        if items.count > limit { items.removeLast(items.count - limit) }
        save(items)
    }

    static func delete(id: String) {
        let kept = load().filter { $0.id != id }
        save(kept)
    }

    static func deleteAll() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

extension ChatSummary {
    var keyWord: String { topic ?? "AI Mentor" }
    var details: String { snippet }
}
