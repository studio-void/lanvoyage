//
//  ChatHistoryView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import Foundation
import SwiftUI

enum ChatHistoryStore {
    private static var _items: [ChatSummary] = []

    static func append(_ summary: ChatSummary) {
        _items.insert(summary, at: 0)
    }

    static func all() -> [ChatSummary] {
        _items
    }

    static func remove(atOffsets offsets: IndexSet) {
        _items.remove(atOffsets: offsets)
    }

    static func clear() { _items.removeAll() }
}
