//
//  StudyRecord.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import Foundation
import SwiftData

enum StudyMode: Int, Codable, CaseIterable, Sendable {
    case mode1 = 1   // Translation Challenge
    case mode2 = 2   // Quick Response
    case mode3 = 3   // AI Prompt
}

@Model
final class StudyRecord {
    @Attribute(.unique) var id: UUID
    var mode: StudyMode
    var createdAt: Date
    var score: Int
    var durationSeconds: Int
    var points: Int

    init(
        id: UUID = UUID(),
        mode: StudyMode,
        createdAt: Date = .now,
        score: Int,
        durationSeconds: Int,
        points: Int
    ) {
        self.id = id
        self.mode = mode
        self.createdAt = createdAt
        self.score = max(0, min(100, score))
        self.durationSeconds = max(0, durationSeconds)
        self.points = max(0, points)
    }
}


extension StudyRecord {
    @discardableResult
    static func save(
        mode: StudyMode,
        score: Int,
        durationSeconds: Int,
        points: Int,
        in context: ModelContext
    ) -> StudyRecord {
        let rec = StudyRecord(
            mode: mode,
            score: score,
            durationSeconds: durationSeconds,
            points: points
        )
        context.insert(rec)
        return rec
    }

    static func fetchAll(in context: ModelContext) -> [StudyRecord] {
        let descriptor = FetchDescriptor<StudyRecord>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    static func fetchRecent(days: Int, in context: ModelContext) -> [StudyRecord] {
        let from = Calendar.current.date(byAdding: .day, value: -abs(days), to: Date()) ?? .distantPast
        let predicate = #Predicate<StudyRecord> { $0.createdAt >= from }
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    static func fetch(mode: StudyMode, in context: ModelContext) -> [StudyRecord] {
        let descriptor = FetchDescriptor<StudyRecord>(
            predicate: #Predicate { $0.mode == mode },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}

struct StudyStats: Sendable {
    let count: Int
    let totalSeconds: Int
    let totalPoints: Int
    let averageScore: Double
    let averageDurationSeconds: Double

    static let empty = StudyStats(
        count: 0,
        totalSeconds: 0,
        totalPoints: 0,
        averageScore: 0,
        averageDurationSeconds: 0
    )
}

extension Array where Element == StudyRecord {
    func stats() -> StudyStats {
        guard isEmpty == false else { return .empty }
        let totalSeconds = reduce(0) { $0 + $1.durationSeconds }
        let totalPoints  = reduce(0) { $0 + $1.points }
        let scoreSum     = reduce(0) { $0 + $1.score }
        let c = count
        return StudyStats(
            count: c,
            totalSeconds: totalSeconds,
            totalPoints: totalPoints,
            averageScore: Double(scoreSum) / Double(c),
            averageDurationSeconds: Double(totalSeconds) / Double(c)
        )
    }
}
