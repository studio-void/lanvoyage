//
//  ChatView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
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

    private let model: GenerativeModel

    // MARK: - Init (Gemini + 시스템 프롬프트)
    var autoFocus: Bool = true
    init(autoFocus: Bool = true) {
        self.autoFocus = autoFocus

        let firebase = FirebaseAI.firebaseAI()

        let systemPrompt = ModelContent(
            role: "system",
            parts: ["""
            너는 GIST 학생들의 외국어(특히 영어) 학습을 돕는 AI 멘토야.
            - 영어 학습 질문에는 간단한 설명과 예문 2개 이상을 제공해.
            - 진로/학습 전략은 단계별로, 실행 가능한 조언으로 정리해.
            - 답변은 너무 길지 않게, 쉬운 문장으로 또박또박 하도록 해.
            """]
        )

        self.model = firebase.generativeModel(
            modelName: "gemini-2.0-flash-001",
            systemInstruction: systemPrompt
        )
    }

    // MARK: - State
    @State private var messages: [ChatMessage] = [
        .init(role: .bot, text: "Hi there! I'm your AI mentor.\nHow can I help you today?")
    ]
    @State private var input: String = ""
    @FocusState private var focused: Bool
    @State private var scrollTarget: UUID?
    @State private var busy = false

    // MARK: - UI
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(messages) { m in
                        messageRow(m)
                            .id(m.id)
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .scrollIndicators(.hidden)
            .contentShape(Rectangle())
            .onTapGesture { focused = false }
            .scrollPosition(id: $scrollTarget)

            inputBar
        }
        .navigationTitle("AI Mentor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if autoFocus { focused = true }
            scrollTarget = messages.last?.id
        }
        .onChange(of: messages.last?.id) {
            scrollTarget = messages.last?.id
        }
    }

    // MARK: - Row
    @ViewBuilder
    private func messageRow(_ m: ChatMessage) -> some View {
        if m.role == .user {
            HStack(alignment: .top, spacing: 8) {
                Spacer(minLength: 0)

                bubble(m.text, isUser: true)

                VStack(spacing: 2) {
                    Text("GIST")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    userAvatar
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)

        } else {
            HStack(alignment: .top, spacing: 8) {
                VStack(spacing: 2) {
                    Text("AI Mentor")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    botAvatar
                }

                bubble(m.text, isUser: false)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Bubble
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

    // MARK: - Avatars
    private var botAvatar: some View {
        Circle()
            .fill(Color(.systemGray5))
            .frame(width: 28, height: 28)
            .overlay(Image(systemName: "person.crop.circle.fill").foregroundColor(.gray))
    }

    private var userAvatar: some View {
        Circle()
            .fill(Color.violet200)
            .frame(width: 28, height: 28)
            .overlay(Image(systemName: "person.crop.circle.fill").foregroundColor(.white))
    }

    // MARK: - Input
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

    // MARK: - Gemini Call
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
                for try await chunk in try model.generateContentStream(text) {
                    if let t = chunk.text, !t.isEmpty {
                        bot.text += t
                        messages[botIndex] = bot
                        scrollTarget = bot.id
                    }
                }
            } catch {
                do {
                    let res = try await model.generateContent(text)
                    bot.text = res.text ?? "(no response)"
                    messages[botIndex] = bot
                } catch {
                    messages[botIndex].text = "오류: \(error.localizedDescription)"
                }
            }
            busy = false
        }
    }
}

#Preview {
    NavigationStack { ChatView(autoFocus: false) }
}
