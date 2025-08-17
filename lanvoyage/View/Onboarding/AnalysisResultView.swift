//
//  AnalysisResultView.swift
//  lanvoyage
//
// Created by Yeeun on 8/17/25.
//


import SwiftUI
import SwiftData
import VoidUtilities

struct AnalysisResultView: View {
    @Query(sort: \StudyRecord.createdAt, order: .reverse)
    private var records: [StudyRecord]
    
    private var accuracyPercent: Int {
        guard records.isEmpty == false else { return 0 }
        let sum = records.reduce(0) { $0 + $1.score }
        return max(0, min(100, Int(round(Double(sum) / Double(records.count)))))
    }
    
    private var totalMinutes: Int {
        let secs = records.reduce(0) { $0 + $1.durationSeconds }
        return secs / 60
    }
    
    private var totalPoints: Int {
        records.reduce(0) { $0 + $1.points }
    }
    
    private var deltaAccuracy: Int {
        guard records.count > 1 else { return 0 }
        let today = records[0].score
        let yesterday = records[1].score
        guard yesterday > 0 else { return 0 }
        return Int(round(Double(today - yesterday) / Double(yesterday) * 100))
    }

    private var deltaMinutes: Int {
        guard records.count > 1 else { return 0 }
        let today = records[0].durationSeconds / 60
        let yesterday = records[1].durationSeconds / 60
        guard yesterday > 0 else { return 0 }
        return Int(round(Double(today - yesterday) / Double(yesterday) * 100))
    }

    private var deltaPoints: Int {
        guard records.count > 1 else { return 0 }
        let today = records[0].points
        let yesterday = records[1].points
        guard yesterday > 0 else { return 0 }
        return Int(round(Double(today - yesterday) / Double(yesterday) * 100))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack {
                    Text("Results")
                        .font(.title3).fontWeight(.bold)
                        .padding(.top, 8)
                    
                    Text("AI Communication Mastery")
                        .font(.title3).fontWeight(.semibold)
                        .padding(20)
                    
                    HStack(spacing: 12) {
                        ResultStatCard(
                            title: "정확도",
                            value: "\(accuracyPercent)%",
                            deltaPercent: deltaAccuracy
                        )
                        ResultStatCard(
                            title: "학습 시간",
                            value: "\(totalMinutes) min",
                            deltaPercent: deltaMinutes
                        )
                    }

                        ResultStatCard(
                        title: "포인트 획득",
                        value: "\(totalPoints)",
                        deltaPercent: deltaPoints
                    )
                    
                    VStack(alignment: .center, spacing: 12) {
                        VStack {
                        }
                        Text("학습 경향 분석")
                            .font(.title3).fontWeight(.semibold)
                        Text("...")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                    .padding(.top, 8)
                    
                    Spacer(minLength: 12)
                }
                .padding(16)
            }
        }
    }
}

private struct ResultStatCard: View {
    let title: String
    let value: String
    let deltaPercent: Int?
    let hint: String?

    init(title: String, value: String, deltaPercent: Int? = nil, hint: String? = nil) {
        self.title = title
        self.value = value
        self.deltaPercent = deltaPercent
        self.hint = hint
    }

    private var deltaText: String? {
        guard let d = deltaPercent else { return nil }
        let sign = d > 0 ? "+" : ""
        return "\(sign)\(d)%"
    }
    private var deltaColor: Color {
        guard let d = deltaPercent else { return .secondary }
        if d >= 0 { return .green }
        if d < 0 { return .red }
        return .secondary
    }

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            if let delta = deltaText {
                Text(delta)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(deltaColor)
            }

            if let hint {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

#Preview {
    AnalysisResultView()
        .modelContainer(for: StudyRecord.self, inMemory: true)
}
