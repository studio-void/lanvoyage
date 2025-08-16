//
//  AIMentorView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/16/25.
//

import SwiftUI

struct ChattingMainView: View {
    @State private var showChat = false
    @State private var isPressing = false
    @State private var summaries: [ChatSummary] = []

    @State private var showDeleteDialog = false
    @State private var targetToDelete: ChatSummary?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Spacer()
                    Text("AI Mentor")
                        .font(.title3).fontWeight(.bold)
                    Spacer()
                }
                .padding(.bottom, 12)

                Text("AI Mentor와 대화해보세요!")
                    .font(.title2).fontWeight(.bold)

                CustomButtonView(
                    title: "채팅하러 가기",
                    kind: isPressing ? .filled : .outline
                )
                .onLongPressGesture(
                    minimumDuration: 0,
                    maximumDistance: 50,
                    pressing: { down in isPressing = down },
                    perform: { showChat = true }
                )

                Text("채팅 기록 모아보기")
                    .font(.headline)
                    .padding(.top, 30)

                if summaries.isEmpty {
                    Text("채팅 기록이 없습니다.")
                        .foregroundColor(.gray)
                        .padding(.top, 16)
                } else {
                    let columns = [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16),
                    ]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        ForEach(Array(summaries.prefix(10))) { s in
                            ChatCardView(
                                title: s.title,
                                keyWord: s.keyWord,
                                details: s.details
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 16))
                            .onLongPressGesture {
                                targetToDelete = s
                                showDeleteDialog = true
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    delete(summary: s)
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.visible)
        .onAppear { summaries = ChatStore.load() }
        .confirmationDialog(
            "이 기록을 삭제할까요?",
            isPresented: $showDeleteDialog,
            presenting: targetToDelete
        ) { s in
            Button("삭제", role: .destructive) { delete(summary: s) }
            Button("취소", role: .cancel) { }
        } message: { _ in
            Text("삭제 후에는 되돌릴 수 없습니다.")
        }
        .fullScreenCover(isPresented: $showChat, onDismiss: {
            summaries = ChatStore.load()
            isPressing = false
        }) {
            NavigationStack {
                ChatView(autoFocus: true) {
                    showChat = false
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar(.visible, for: .navigationBar)
            }
        }
    }

    private func delete(summary: ChatSummary) {
        ChatStore.delete(id: summary.id)
        summaries = ChatStore.load()
    }
}

private struct ChatCardView: View {
    var title: String
    var keyWord: String
    var details: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote)
                .foregroundColor(.black.opacity(0.8))
                .lineLimit(1)

            Text(keyWord)
                .font(.headline).bold()
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(details)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
                .lineLimit(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 148)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ChattingMainView()
}
