//
//  OnBoardingFinshView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/14/25.
//

import SwiftUI
import VoidUtilities   // Color.violet500/토큰이 여기 있다면 유지

// 디자인 토큰(프로젝트에 이미 있으면 아래 값은 무시됨)
enum Constants {
    static let white  = Color.white
    static let border = Color.black.opacity(0.12)
}

struct OnboardingCharacterView: View {
    // 레벨은 외부 주입 가능. 데모용 기본값
    @State private var level: Int = 1

    // SelectionChip 상태
    @State private var selMeeting = false
    @State private var selMail   = true
    @State private var selAI     = false

    // 헤더↔카드 간격 / 카드 고정 크기
    private let headerCardGap: CGFloat = 24
    private let cardHeight: CGFloat = 522

    var body: some View {
        VStack(spacing: 16) {
            Header(level: level)

            CharacterCard(
                level: level,
                selMeeting: $selMeeting,
                selMail: $selMail,
                selAI: $selAI
            )
            .padding(.top, headerCardGap)                              // 헤더와 간격 확보
            .frame(maxWidth: .infinity, minHeight: cardHeight, alignment: .top)

            Spacer(minLength: 0)

            BottomButtonBar(
                onBack: {
                    // 이전 액션
                },
                onStart: {
                    // 시작하기 액션(선택 칩 확인 예시)
                    let selected = [
                        selMeeting ? "회의" : nil,
                        selMail   ? "메일" : nil,
                        selAI     ? "AI 보정" : nil
                    ].compactMap { $0 }
                    print("선택:", selected)
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Header

private struct Header: View {
    let level: Int
    var body: some View {
        VStack(spacing: 8) {
            Text("당신은 Lv\(level)")
                .font(.title2.weight(.semibold))
            Text("한국어 마스터 입니다.")
                .font(.title2.weight(.bold))
            Text("설문 결과를 바탕으로 맞춤 캐릭터를 추천해드렸어요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }
}

// MARK: - Character Card

private struct CharacterCard: View {
    let level: Int
    @Binding var selMeeting: Bool
    @Binding var selMail: Bool
    @Binding var selAI: Bool

    var body: some View {
        VStack(spacing: 16) {
            CharacterImage()

            VStack(spacing: 6) {
                Text("비즈니스 협상가 Lv\(level) : 대리")
                    .font(.headline)
                Text("업무 이메일, 회의 표현부터\nAI 번역 보정까지 단계적으로 학습")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // 새로운 InformationChipButton 3개
            HStack(spacing: 8) {
                Spacer()
                InformationChipButton(
                    title: "회의",
                    kind: .tinted,
                    tint: .mint
                ) { selMeeting.toggle() }
                Spacer()
                InformationChipButton(
                    title: "메일",
                    kind: .outlined
                ) { selMail.toggle() }
                Spacer()
                InformationChipButton(
                    title: "AI 보정",
                    kind: .plain
                ) { selAI.toggle() }
                Spacer()
            }
        }
        .padding(20)
        .background(Constants.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .inset(by: 0.5)
                .stroke(Constants.border, lineWidth: 1)
        )
    }
}

// MARK: - Character Image

private struct CharacterImage: View {
    var body: some View {
        if let ui = UIImage(named: "character_default") {
            Image(uiImage: ui)
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.violet500, .blue],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 4)
        }
    }
}

// MARK: - Bottom Button Bar (CustomButtonView 사용)

private struct BottomButtonBar: View {
    var onBack: () -> Void
    var onStart: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemGroupedBackground))
                .frame(height: 76)

            GeometryReader { proxy in
                let spacing: CGFloat = 16
                let w1 = (proxy.size.width - spacing) / 3
                let w2 = (proxy.size.width - spacing) * 2 / 3

                HStack(spacing: spacing) {
                    CustomButtonView(title: "이전", kind: .outline)
                        .frame(width: w1)

                    CustomButtonView(title: "이제 시작하기!", kind: .filled)
                        .frame(width: w2)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        OnboardingCharacterView()
    }
}
