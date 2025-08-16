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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Spacer()
                    Text("AI Mentor")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.top, 0)
                .padding(.bottom, 12)

                Text("AI Mentor와 대화해보세요!")
                    .font(.title2)
                    .fontWeight(.bold)

                CustomButtonView(
                    title: "채팅하러 가기",
                    kind: isPressing ? .filled : .outline
                )
                .onLongPressGesture(
                    minimumDuration: 0,
                    maximumDistance: 50,
                    pressing: { down in
                        isPressing = down
                    },
                    perform: {
                        showChat = true
                    }
                )

                Text("채팅 기록 모아보기")
                    .font(.headline)
                    .padding(.top, 30)

                let columns = [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                ]

                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ChatCardView(
                        title: "AI 영어 효율적 공부",
                        keyWord: "문맥 이해",
                        details: "단순 번역이 아닌\n문화적 뉘앙스 이해"
                    )
                    ChatCardView(
                        title: "스피킹 발음 교정",
                        keyWord: "발음, 억양",
                        details: "발음 오류 즉시 교정,\n억양 개선 훈련"
                    )
                    ChatCardView(
                        title: "AI로 해외 뉴스 분석",
                        keyWord: "시사 영어",
                        details: "최신 글로벌 뉴스의\n핵심 영어 표현 학습"
                    )
                    ChatCardView(
                        title: "이메일 영어 피드백",
                        keyWord: "비즈니스",
                        details: "작성한 이메일 검토,\n자연스럽게 고치기"
                    )
                }
            }
            .padding(.bottom, 24)
        }
        .fullScreenCover(isPresented: $showChat) {
            NavigationStack {
                ChatView()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .toolbar(.visible, for: .navigationBar)
                    .navigationBarHidden(false)
            }
        }
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

            Text(keyWord)
                .font(.headline).bold()
                .foregroundColor(.primary)

            Text(details)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

#Preview {
    ChattingMainView()
}
