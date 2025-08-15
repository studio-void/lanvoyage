//
//  OnBoardingFinshView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/14/25.
//

import SwiftUI
import VoidUtilities

enum Constants {
    static let white  = Color.white
    static let border = Color(hex: "#DBE0E5")
}

struct OnboardingCharacterView: View {
    @State private var level: Int = 1

    @State private var selMeeting = false
    @State private var selMail   = true
    @State private var selAI     = false

    private let headerCardGap: CGFloat = 24
    private let cardMinHeight: CGFloat = 522

    var body: some View {
        VStack(spacing: 16) {
            Header(level: level)

            CharacterCard(
                level: level,
                selMeeting: $selMeeting,
                selMail: $selMail,
                selAI: $selAI
            )
            .padding(.top, headerCardGap)
            .frame(maxWidth: .infinity, minHeight: cardMinHeight, alignment: .top)

            Spacer(minLength: 0)

            let isStartEnabled = selMeeting || selMail || selAI
            BottomButtonBar(
                isNextEnabled: isStartEnabled,
                destination: MainView()
            )
        }
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

            HStack(spacing: 8) {
                InformationChipButton(
                    title: "회의",
                    kind: .tinted,
                    tint: .mint
                ) { selMeeting.toggle() }
                .frame(maxWidth: .infinity)

                InformationChipButton(
                    title: "메일",
                    kind: .outlined
                ) { selMail.toggle() }
                .frame(maxWidth: .infinity)

                InformationChipButton(
                    title: "AI 보정",
                    kind: .plain
                ) { selAI.toggle() }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .background(Constants.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .inset(by: 0.5)
                .stroke(Constants.border, lineWidth: 1)
        )
    }
}


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


private struct BottomButtonBar<Destination: View>: View {
    @Environment(\.presentationMode) private var presentationMode
    @State private var showMain = false

    var isNextEnabled: Bool
    var destination: Destination

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 12
            let w1 = (proxy.size.width - spacing) / 3
            let w2 = (proxy.size.width - spacing) * 2 / 3
            let nextKind: CustomButtonView.Kind = isNextEnabled ? .filled : .disabled

            HStack(spacing: spacing) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    CustomButtonView(title: "이전", kind: .outline)
                        .frame(width: w1)
                        .padding(.leading, 0.2)
                }

                Button {
                    if isNextEnabled { showMain = true }
                } label: {
                    CustomButtonView(title: "다음", kind: nextKind)
                        .frame(width: w2)
                        .padding(.trailing, 0.2)
                }
                .disabled(!isNextEnabled)
            }
        }
        .frame(height: 49)
        .fullScreenCover(isPresented: $showMain) {
            destination
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingCharacterView()
    }
}
