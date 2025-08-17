//
//  ChatScenarioView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/15/25.
//

import SwiftUI
import VoidUtilities
import FirebaseAI
import SwiftData

struct ChatScenario {
    var headerTitle: String = "AI Tool Master"
    var headerSubtitle: String
    var systemPrompt: String
    var initialBotMessage: String
    var onSave: (ChatSummary, [ChatScreenView.ChatMessage]) -> Void = { s, _ in
        ChatStore.append(s)
    }
}

struct ChatScreenView: View {
    enum Role { case user, bot }
    struct ChatMessage: Identifiable {
        let id = UUID()
        let role: Role
        var text: String
    }

    @Environment(\.modelContext) private var modelContext
    @State private var userPointsManager = UserPointsManager()

    var scenario: ChatScenario
    var onClose: () -> Void = {}
    var autoFocus: Bool = true

    private let chatModel: GenerativeModel
    private let scoringModel: GenerativeModel

    init(autoFocus: Bool = true, onClose: @escaping () -> Void = {}) {
        self.init(
            scenario: .init(
                headerSubtitle: "Essay Master",
                systemPrompt: """
                너는 GIST 학생들의 외국어(특히 영어) 학습을 돕는 AI 멘토야.
                - 영어 학습 질문에는 간단한 설명과 예문 2개 이상을 제공해.
                - 진로/학습 전략은 단계별로, 실행 가능한 조언으로 정리해.
                - 답변은 너무 길지 않게, 쉬운 문장으로 또박또박 하도록 해.
                """,
                initialBotMessage: "GIST님께서 작성하고자 하는 Essay의 키워드와 주제 등을 입력해주세요! 많은 정보를 주실수록 양질의 에세이가 생성됩니다 :)"
            ),
            autoFocus: autoFocus,
            onClose: onClose
        )
    }

    init(
        scenario: ChatScenario,
        autoFocus: Bool = true,
        onClose: @escaping () -> Void = {}
    ) {
        self.scenario = scenario
        self.autoFocus = autoFocus
        self.onClose = onClose

        let ai = FirebaseAI.firebaseAI()

        let systemPrompt = ModelContent(role: "system", parts: [scenario.systemPrompt])
        self.chatModel = ai.generativeModel(
            modelName: "gemini-2.0-flash-001",
            systemInstruction: systemPrompt
        )

        let scoreSchema = Schema.object(
            properties: [
                "score": .integer(description: "0~100 사이의 정수 점수"),
                "reason": .string(description: "점수 근거 요약, 최대 80자")
            ]
        )
        self.scoringModel = ai.generativeModel(
            modelName: "gemini-2.5-flash",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: scoreSchema
            )
        )
    }

    @State private var messages: [ChatMessage] = []
    @State private var input: String = ""
    @FocusState private var focused: Bool
    @State private var busy = false
    @State private var savingFinal = false
    @State private var showSavedAlert = false
    @State private var sessionStart = Date()

    private let maxContextTurns = 10

    @State private var score3: Int = 0
    var durationSeconds3: Int { Int(Date().timeIntervalSince(sessionStart)) }
    var pointsToAddMode3: Int { max(0, min(100, score3)) / 10 + (durationSeconds3 / 1800) }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(messages) { m in
                        messageRow(m).id(m.id)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .contentShape(Rectangle())
            .onTapGesture { focused = false }
            .defaultScrollAnchor(.bottom)
            .onAppear {
                if messages.isEmpty {
                    messages = [.init(role: .bot, text: scenario.initialBotMessage)]
                    sessionStart = Date()
                }
                if autoFocus { focused = true }
                if let last = messages.last?.id { proxy.scrollTo(last, anchor: .bottom) }
            }
            .onChange(of: messages.last?.id) { _, new in
                guard let new else { return }
                withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(new, anchor: .bottom) }
            }
            .safeAreaInset(edge: .bottom) {
                inputBar
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(scenario.headerTitle).font(.headline)
                    Text(scenario.headerSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: saveFinalDocument) {
                    Text("최종본 생성")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.violet500))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .disabled(savingFinal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("저장 완료", isPresented: $showSavedAlert) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("History에서 최종본을 확인할 수 있어요.")
        }
    }

    @ViewBuilder
    private func messageRow(_ m: ChatMessage) -> some View {
        if m.role == .user {
            HStack(alignment: .top, spacing: 8) {
                Spacer(minLength: 0)
                bubble(m.text, isUser: true)
                VStack(spacing: 2) {
                    Text("GIST").font(.caption2).foregroundColor(.gray)
                    userAvatar
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Text("AI Mentor").font(.caption2).foregroundColor(.gray)
                    botAvatar
                }
                bubble(m.text, isUser: false)
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func bubble(_ text: String, isUser: Bool) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(isUser ? .white : .primary)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isUser ? Color.violet500 : Color(.systemGray6))
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
    }

    private var botAvatar: some View {
        Circle().fill(Color(.systemGray5)).frame(width: 28, height: 28)
            .overlay(Image(systemName: "person.crop.circle.fill").foregroundColor(.gray))
    }
    private var userAvatar: some View {
        Circle().fill(Color.violet200).frame(width: 28, height: 28)
            .overlay(Image(systemName: "person.crop.circle.fill").foregroundColor(.white))
    }

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("AI 멘토와 대화해보세요.", text: $input, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.callout)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .focused($focused)

            Button(action: send) {
                Image(systemName: busy ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
            }
            .disabled(busy || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.98))
    }

    private func send() {
        let text = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, busy == false else { return }

        messages.append(.init(role: .user, text: text))
        input = ""

        var bot = ChatMessage(role: .bot, text: "")
        messages.append(bot)
        let botIndex = messages.count - 1
        busy = true

        let prompt = contextPrompt(text)

        Task {
            do {
                for try await chunk in try chatModel.generateContentStream(prompt) {
                    if let t = chunk.text, !t.isEmpty {
                        bot.text += t
                        messages[botIndex] = bot
                    }
                }
            } catch {
                do {
                    let res = try await chatModel.generateContent(prompt)
                    bot.text = res.text ?? "(no response)"
                    messages[botIndex] = bot
                } catch {
                    messages[botIndex].text = "오류: \(error.localizedDescription)"
                }
            }
            busy = false
        }
    }

    private func contextPrompt(_ latestUserText: String) -> String {
        let rows = messages.map { m -> String in
            m.role == .user ? "학생: \(m.text.replacingOccurrences(of: "\n", with: " "))"
                            : "AI: \(m.text.replacingOccurrences(of: "\n", with: " "))"
        }
        let tail = Array(rows.suffix(maxContextTurns * 2))
        let joined = tail.joined(separator: "\n")
        let system = """
        역할: \(scenario.systemPrompt)
        지침: 대화 맥락을 유지하고, 불명확하면 2~3개의 질문으로 요구사항을 좁힌다.
        """
        return [system, joined, "학생: \(latestUserText)", "AI:"].joined(separator: "\n")
    }

    private func saveFinalDocument() {
        guard let lastBot = messages.last(where: { $0.role == .bot })?.text else { return }
        let finalBody = extractFinalEssay(from: lastBot).trimmingCharacters(in: .whitespacesAndNewlines)
        guard finalBody.isEmpty == false else { return }

        let firstLine = finalBody.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true).first ?? Substring("Essay")
        let title = String(firstLine.prefix(24))
        let snippet = String(finalBody.prefix(60))

        let summary = ChatSummary(
            id: UUID().uuidString,
            title: title,
            snippet: snippet,
            timestamp: Date(),
            topic: scenario.headerSubtitle,
            messageCount: messages.count
        )

        savingFinal = true
        Task {
            let (scored, reason) = await scoreFinalEssay(finalBody)
            score3 = scored

            ChatHistoryStore.append(summary: summary, fullText: finalBody)
            ChatHistoryStore.setDuration(for: summary.id, seconds: durationSeconds3)
            ChatHistoryStore.setScore(for: summary.id, score: scored, reason: reason)

            StudyRecordManager.add(
                context: modelContext,
                mode: .mode3,
                score: score3,
                durationSeconds: durationSeconds3,
                points: pointsToAddMode3
            )

            userPointsManager.addPoints(pointsToAddMode3)

            scenario.onSave(summary, messages)
            savingFinal = false
            showSavedAlert = true
        }
    }

    private func scoreFinalEssay(_ text: String) async -> (Int, String) {
        let rubric = """
        아래 글을 0~100점으로 채점하라.
        기준: 논지명료성(25) 구조/전개(25) 근거/예시(20) 문장력/문법(20) 결론/시사점(10).
        JSON만 반환: {"score": <정수 0..100>, "reason": "<80자 이내 근거 요약>"}.
        글:
        \(text)
        """
        do {
            let res = try await scoringModel.generateContent(rubric)
            if let t = res.text, let data = t.data(using: .utf8) {
                struct ScoreJSON: Decodable { let score: Int; let reason: String? }
                if let parsed = try? JSONDecoder().decode(ScoreJSON.self, from: data) {
                    let s = max(0, min(100, parsed.score))
                    return (s, parsed.reason ?? "")
                }
            }
        } catch { }
        let wc = max(0, text.split { $0.isWhitespace || $0.isNewline }.count)
        let fallback = max(40, min(95, 50 + wc/20))
        return (fallback, "자동 백업 채점")
    }

    private func extractFinalEssay(from raw: String) -> String {
        let t = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if let r1 = t.range(of: "```"), let r2 = t.range(of: "```", range: r1.upperBound..<t.endIndex) {
            return String(t[r1.upperBound..<r2.lowerBound])
        }
        if let r = t.range(of: "최종본") ?? t.range(of: "Final") ?? t.range(of: "final", options: .caseInsensitive) {
            let after = t[r.upperBound...]
            return String(after).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return t
    }
}

enum Scenarios {
    static let essay = ChatScenario(
        headerSubtitle: "Essay Master",
        systemPrompt: """
        너는 학술 에세이 멘토다. 서론-본론-결론 구조와 주제문/전환을 지도한다.
        모호하면 2~3개의 명확 질문으로 요구사항을 좁혀라.
        """,
        initialBotMessage: "에세이 주제/키워드를 알려주면 구조부터 같이 잡아볼게요.",
        onSave: { summary, _ in
            ChatHistoryStore.append(summary)
        }
    )

    static let citation = ChatScenario(
        headerSubtitle: "Citation Helper",
        systemPrompt: """
        너는 인용/참고문헌 도우미다. APA/MLA 예시와 본문 내 인용을 제시하고,
        변경 이유를 간단히 설명한다.
        """,
        initialBotMessage: "형식(APA/MLA)과 출처 정보를 알려주면 인용 예시를 만들어줄게요.",
        onSave: { summary, _ in
            ChatHistoryStore.append(summary)
        }
    )
}

#Preview {
    NavigationStack {
        ChatScreenView(scenario: Scenarios.essay, autoFocus: false)
    }
}
