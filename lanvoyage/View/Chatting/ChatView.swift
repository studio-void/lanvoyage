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

    var autoFocus: Bool = true
    init(autoFocus: Bool = true) {
        self.autoFocus = autoFocus
        let firebase = FirebaseAI.firebaseAI()
        self.model = firebase.generativeModel(modelName: "gemini-2.0-flash-001")
    }

    @State private var messages: [ChatMessage] = [
        .init(role: .bot, text: "Hi there! I'm your AI mentor.\nHow can I help you today?")
    ]
    @State private var input: String = ""
    @FocusState private var focused: Bool
    @State private var scrollTarget: UUID?
    @State private var busy = false

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
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                HStack(spacing: 8) {
                    Spacer()
                    bubble(m.text, isUser: true)
                        .overlay(alignment: .topTrailing) {
                            Text("GIST")
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.top, -12)
                                .padding(.trailing, 4)
                        }
                    userAvatar
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Text("AI Mentor")
                    .font(.caption2)
                    .foregroundColor(.gray)
                HStack(spacing: 8) {
                    botAvatar
                    bubble(m.text, isUser: false)
                    Spacer(minLength: 0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func bubble(_ text: String, isUser: Bool) -> some View {
        HStack {
            if isUser { Spacer() }
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
        }
        .frame(maxWidth: 280, alignment: isUser ? .trailing : .leading)
    }

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

    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("AI 멘토와 대화해보세요.", text: $input, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.callout)
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .focused($focused)

            Button { send() } label: {
                Image(systemName: busy ? "stop.circle.fill" : "arrow.up.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
            }
            .disabled(busy || input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground).opacity(0.98))
    }

    // MARK: - Gemini 호출
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
