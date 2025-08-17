//
//  LearnModeView.swift
//  lanvoyage
//
//  Created by Yeeun on 8/17/25.
//

import SwiftUI

struct LearnMode: Identifiable, Hashable {
    let id: String
    let ribbon: String
    let indexLabel: String
    let title: String
    let subtitle: String
    let accent: Color
    let illustrationName: String
}


struct LearnModeView: View {
    @State private var goStudent: Bool = false

    private let modes: [LearnMode] = [
        .init(id: "student",
              ribbon: "STUDENT MODE",
              indexLabel: "Mode 1",
              title: "Student Mode",
              subtitle: "Essay, Academic, writing",
              accent: .purple,
              illustrationName: "StudentMode"),
        .init(id: "business",
              ribbon: "Business Mode",
              indexLabel: "Mode 2",
              title: "Business Mode",
              subtitle: "Reports, Emails,\nMeetings",
              accent: .blue,
              illustrationName: "BusinessMode"),
        .init(id: "casual",
              ribbon: "Casual Mode",
              indexLabel: "Mode 3",
              title: "Casual Mode",
              subtitle: "Articles, News,\nMagazines",
              accent: .orange,
              illustrationName: "CasualMode")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("AI, 나의 든든한 조력자")
                        .font(.title2).bold()

                    Text("AI, 이제는 제대로 알고 200% 활용하자!")
                        .font(.subheadline)
                        .foregroundStyle(.primary.opacity(0.8))

                    Text("추천학습")
                        .font(.title3).bold()
                        .padding(.top, 8)

                    VStack(spacing: 14) {
                        ForEach(modes) { mode in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(mode.ribbon)
                                    .font(.caption).bold()
                                    .foregroundStyle(.secondary)

                                ModeCard(
                                    mode: mode,
                                    isEnabled: mode.id == "student",
                                    onEnter: {
                                        goStudent = true
                                    }
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
            .navigationDestination(isPresented: $goStudent) {
                StudentHomeModeView()
            }
        }
    }
}


private struct ModeCard: View {
    let mode: LearnMode
    let isEnabled: Bool
    let onEnter: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {

            VStack(alignment: .leading, spacing: 6) {
                Text(mode.indexLabel)
                    .font(.caption)
                    .foregroundStyle(.primary)

                Text(mode.title)
                    .font(.title3).bold()

                Text(mode.subtitle)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                Button(action: {
                    if isEnabled { onEnter() }
                }) {
                    CustomButtonView(
                        title: "입장하기",
                        kind: isEnabled ? .outline : .disabled
                    )
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            IllustrationPane(imageName: mode.illustrationName, accent: mode.accent)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.black.opacity(0.05), lineWidth: 0.5)
        )
        .shadow(color: .black.opacity(0.06), radius: 10, y: 4)
    }
}

private struct IllustrationPane: View {
    let imageName: String
    let accent: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(accent.opacity(0.10))

            Image(imageName)
                .resizable()
                .scaledToFit()
                .padding(8)
        }
        .frame(width: 112, height: 112)
    }
}

#Preview {
    LearnModeView()
}
