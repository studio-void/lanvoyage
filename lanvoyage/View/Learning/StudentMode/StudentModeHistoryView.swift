//
//  StudentModeHistoryView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import SwiftUI

struct StudentModeHistoryView: View {
    let title: String
    let items: [ChatSummary]
    var onSelect: (ChatSummary) -> Void = { _ in }
    var onDelete: (IndexSet) -> Void = { _ in }

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { s in
                    if let full = ChatHistoryStore.fullText(for: s.id) {
                        NavigationLink {
                            HistoryDetailView(summary: s, fullText: full)
                        } label: {
                            HistoryRow(summary: s)
                        }
                        .buttonStyle(.plain)
                    } else {
                        HistoryRow(summary: s)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(s) }
                    }
                }
                .onDelete(perform: onDelete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle(title)
        }
    }
}

private struct HistoryRow: View {
    let summary: ChatSummary
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(summary.title).font(.headline)
            Text(summary.snippet).font(.subheadline).foregroundStyle(.secondary).lineLimit(2)
            Text(Self.fmt.string(from: summary.timestamp)).font(.caption).foregroundStyle(.secondary).padding(.top, 2)
        }
    }
    private static let fmt: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .short; df.timeStyle = .short
        return df
    }()
}

struct HistoryDetailView: View {
    let summary: ChatSummary
    let fullText: String
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(summary.title).font(.title2).bold()
                Text(fullText).font(.body)
            }
            .padding(16)
        }
        .navigationTitle("Final Essay")
        .navigationBarTitleDisplayMode(.inline)
    }
}
