//
//  StudyRecordManager.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import SwiftData
import Foundation

@MainActor
struct StudyRecordManager {
    static func add(
        context: ModelContext,
        mode: StudyMode,
        score: Int,
        durationSeconds: Int,
        points: Int,
        createdAt: Date = .now
    ) {
        let rec = StudyRecord(
            mode: mode,
            createdAt: createdAt,
            score: score,
            durationSeconds: durationSeconds,
            points: points,
        )
        context.insert(rec)
        try? context.save()
    }

    static func fetchAll(context: ModelContext) -> [StudyRecord] {
        let descriptor = FetchDescriptor<StudyRecord>(sortBy: [.init(\.createdAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    static func fetchSince(context: ModelContext, days: Int) -> [StudyRecord] {
        let from = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .distantPast
        let predicate = #Predicate<StudyRecord> { $0.createdAt >= from }
        let descriptor = FetchDescriptor<StudyRecord>(predicate: predicate, sortBy: [.init(\.createdAt, order: .reverse)])
        return (try? context.fetch(descriptor)) ?? []
    }

    static func fetchByMode(context: ModelContext, mode: StudyMode, days: Int? = nil) -> [StudyRecord] {
        if let d = days {
            let from = Calendar.current.date(byAdding: .day, value: -d, to: .now) ?? .distantPast
            let predicate = #Predicate<StudyRecord> { $0.mode == mode && $0.createdAt >= from }
            let descriptor = FetchDescriptor<StudyRecord>(predicate: predicate, sortBy: [.init(\.createdAt, order: .reverse)])
            return (try? context.fetch(descriptor)) ?? []
        } else {
            let predicate = #Predicate<StudyRecord> { $0.mode == mode }
            let descriptor = FetchDescriptor<StudyRecord>(predicate: predicate, sortBy: [.init(\.createdAt, order: .reverse)])
            return (try? context.fetch(descriptor)) ?? []
        }
    }
}
