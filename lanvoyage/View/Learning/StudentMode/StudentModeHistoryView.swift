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
    var onSelect: (ChatSummary) -> Void
    var onDelete: (IndexSet) -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { s in
                    Button {
                        onSelect(s)
                    } label: {
                        HistoryRow(summary: s)
                    }
                    .buttonStyle(.plain)
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
            Text(summary.title)
                .font(.headline)
            Text(summary.snippet)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
