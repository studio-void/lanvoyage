//
//  StudentHomeModeView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//
import SwiftUI
import VoidUtilities

struct StudentHomeModeView: View {
    @State private var showHistory = false
    private let accent = Color.violet500

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Student Mode")
                            .font(.title2).bold()
                        Text("AI와 함께하는 학문적 글쓰기 훈련")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        showHistory = true
                    } label: {
                        Text("History")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(accent, lineWidth: 1)
                            )
                            .foregroundStyle(accent)
                    }
                    .buttonStyle(.plain)
                }

                Text("구체적으로 원하는 기능을 골라보세요!")
                    .font(.title3).bold()
                    .padding(.top, 4)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Essay 구조 짜기 연습")
                        .font(.headline)
                    Text("서론–본론–결론 구조로 아이디어를 조직하는 훈련")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        ChatScreenView(scenario: Scenarios.essay)
                    } label: {
                        CustomButtonView(title: "시작하기!", kind: .outline)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemGray6))
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("문헌 인용 / 참고문헌 표기")
                        .font(.headline)
                    Text("APA/MLA 형식에 맞는 인용 연습과 자연스러운 연결 문장 작성 훈련")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    NavigationLink {
                        ChatScreenView(scenario: Scenarios.citation)
                    } label: {
                        CustomButtonView(title: "시작하기!", kind: .outline)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(.systemGray6))
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Tip!")
                        .font(.headline)
                    Text("AI와 채팅 후 최종본을 저장하고 싶으시면 최종본 생성 버튼을 반드시 눌러주세요!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent, lineWidth: 1)
                )
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.inline)

        .sheet(isPresented: $showHistory) {
            StudentModeHistoryView(
                title: "History",
                items: ChatHistoryStore.all(),
                onSelect: { _ in
                },
                onDelete: { offsets in
                    ChatHistoryStore.remove(atOffsets: offsets)
                }
            )
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationStack {
        StudentHomeModeView()
    }
}
