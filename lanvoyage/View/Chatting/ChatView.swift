//
//  ChatView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/15/25.
//

import SwiftUI
import VoidUtilities
import FirebaseAI

struct ChatView: View {
    enum Role { case user, bot }
    struct ChatMessage: Identifiable {
        let id = UUID()
        let role: Role
        var text: String
    }

    var onClose: () -> Void = {}
    var autoFocus: Bool = true

    private let chatModel: GenerativeModel
    private let summaryModel: GenerativeModel
    
    @AppStorage("userName") var userName: String = "GIST"

    init(autoFocus: Bool = true, onClose: @escaping () -> Void = {}) {
        self.autoFocus = autoFocus
        self.onClose = onClose

        let ai = FirebaseAI.firebaseAI()

        let systemPrompt = ModelContent(
            role: "system",
            parts: ["""
            너는 GIST 학생들의 외국어(특히 영어) 학습을 돕는 AI 멘토야.
            - 영어 학습 질문에는 간단한 설명과 예문 2개 이상을 제공해.
            - 진로/학습 전략은 단계별로, 실행 가능한 조언으로 정리해.
            - 답변은 너무 길지 않게, 쉬운 문장으로 또박또박 하도록 해.
            """]
        )
        self.chatModel = ai.generativeModel(
            modelName: "gemini-2.0-flash-001",
            systemInstruction: systemPrompt
        )

        let jsonSchema = Schema.object(
            properties: [
                "title": .string(description: "대화 주제, 최대 12자"),
                "keyword": .enumeration(values: [
                    "발음 교정","문법","문맥 이해","시사 영어","비즈니스","발표","에세이","어휘","리스닝","학습"
                ]),
                "details": .string(description: "실행할 해결책, 최대 16자, 말줄임표 금지")
            ]
        )
        
        self.summaryModel = ai.generativeModel(
            modelName: "gemini-2.5-flash",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: jsonSchema
            )
        )
    }

    @State private var messages: [ChatMessage] = [
        .init(role: .bot, text: "Hi there! I'm your AI mentor.\nHow can I help you today?")
    ]
    @State private var input: String = ""
    @FocusState private var focused: Bool
    @State private var busy = false
    @State private var summarizing = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(messages) { m in
                        messageRow(m).id(m.id)
                    }
                    if summarizing {
                        ProgressView().padding(.top, 8)
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
        .navigationTitle("AI Mentor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { saveSummaryAndClose() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .padding(10)
                }
                .accessibilityLabel("닫기")
            }
        }
    }

    @ViewBuilder
    private func messageRow(_ m: ChatMessage) -> some View {
        if m.role == .user {
            HStack(alignment: .top, spacing: 8) {
                Spacer(minLength: 0)
                bubble(m.text, isUser: true)
                VStack(spacing: 2) {
                    Text(userName).font(.caption2).foregroundColor(.gray)
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

        Task {
            do {
                for try await chunk in try chatModel.generateContentStream(text) {
                    if let t = chunk.text, !t.isEmpty {
                        bot.text += t
                        messages[botIndex] = bot
                    }
                }
            } catch {
                do {
                    let res = try await chatModel.generateContent(text)
                    bot.text = res.text ?? "(no response)"
                    messages[botIndex] = bot
                } catch {
                    messages[botIndex].text = "오류: \(error.localizedDescription)"
                }
            }
            busy = false
        }
    }

    private func saveSummaryAndClose() {
        summarizing = true
        Task {
            let joined = messages.suffix(12).map { m in
                (m.role == .user ? "학생: " : "AI: ") + m.text.replacingOccurrences(of: "\n", with: " ")
            }.joined(separator: "\n")

            let prompt = """
            대화를 카드로 요약하라.
            title: 대화 주제(최대 12자)
            keyword: 발음 교정/문법/문맥 이해/시사 영어/비즈니스/발표/에세이/어휘/리스닝/학습 중 하나
            details: 실행할 해결책 한 문장(최대 16자, 말줄임표 금지)
            대화:
            \(joined)
            """

            var title = "AI 영어 학습"
            var keyword = "학습"
            var details = "표현 3개 만들기"

            do {
                let res = try await summaryModel.generateContent(prompt)
                if let text = res.text, let data = text.data(using: .utf8) {
                    if let parsed = try? JSONDecoder().decode(CardJSON.self, from: data) {
                        title   = limit(parsed.title,   to: 12)
                        keyword = parsed.keyword
                        details = sanitizeTo16(parsed.details)
                    }
                }
            } catch {
                let lastAsk = messages.last(where: { $0.role == .user })?.text ?? ""
                let cat = heuristicCategory(from: lastAsk)
                title   = limit(cat.title,   to: 12)
                keyword = cat.keyword
                details = "표현 3개 만들기"
            }

            let summary = ChatSummary(
                id: UUID().uuidString,
                title: title,
                snippet: details,
                timestamp: Date(),
                topic: keyword,
                messageCount: messages.count
            )
            ChatStore.append(summary)

            summarizing = false
            withAnimation(.spring(response: 0.36, dampingFraction: 0.9, blendDuration: 0.2)) {
                onClose()
            }
        }
    }

    private func limit(_ s: String, to max: Int) -> String {
        if s.count <= max { return s }
        return String(s.prefix(max))
    }

    private func sanitizeTo16(_ raw: String) -> String {
        var t = raw
            .replacingOccurrences(of: "...", with: "")
            .replacingOccurrences(of: "…", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if t.count > 16 { t = String(t.prefix(16)) }
        let badEnds: [Character] = [",","·","-","—",":",";"]
        while let last = t.last, badEnds.contains(last) { t.removeLast() }
        return t
    }

    private struct CardJSON: Codable {
        let title: String
        let keyword: String
        let details: String
    }

    private enum HeuCat { case pronunciation, grammar, reading, news, business, presentation, essay, vocabulary, listening, general
        var title: String {
            switch self {
            case .pronunciation: return "스피킹 발음 교정"
            case .grammar: return "문법 이해"
            case .reading: return "문맥 이해"
            case .news: return "시사 영어"
            case .business: return "비즈니스 영어"
            case .presentation: return "발표 피드백"
            case .essay: return "에세이/작문"
            case .vocabulary: return "어휘 확장"
            case .listening: return "리스닝 훈련"
            case .general: return "AI 영어 학습"
            }
        }
        var keyword: String {
            switch self {
            case .pronunciation: return "발음 교정"
            case .grammar: return "문법"
            case .reading: return "문맥 이해"
            case .news: return "시사 영어"
            case .business: return "비즈니스"
            case .presentation: return "발표"
            case .essay: return "에세이"
            case .vocabulary: return "어휘"
            case .listening: return "리스닝"
            case .general: return "학습"
            }
        }
    }

    private func heuristicCategory(from text: String) -> HeuCat {
        let t = text.lowercased()
        if t.contains("발음") || t.contains("pronunciation") || t.contains("억양") || t.contains("accent") { return .pronunciation }
        if t.contains("문법") || t.contains("grammar") { return .grammar }
        if t.contains("독해") || t.contains("reading") || t.contains("comprehension") || t.contains("문맥") { return .reading }
        if t.contains("뉴스") || t.contains("시사") || t.contains("news") { return .news }
        if t.contains("비즈니스") || t.contains("business") || t.contains("메일") || t.contains("email") { return .business }
        if t.contains("발표") || t.contains("presentation") || t.contains("프레젠테이션") { return .presentation }
        if t.contains("에세이") || t.contains("essay") || t.contains("작문") || t.contains("writing") { return .essay }
        if t.contains("어휘") || t.contains("단어") || t.contains("vocabulary") { return .vocabulary }
        if t.contains("리스닝") || t.contains("듣기") || t.contains("listening") || t.contains("청해") { return .listening }
        return .general
    }
}

#Preview {
    NavigationStack { ChatView(autoFocus: false) }
}
