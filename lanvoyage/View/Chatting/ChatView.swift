//
//  ChatView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI
import VoidUtilities

struct ChatView: View {
    @State private var text: String = ""

    struct Message: Identifiable {
        enum Role { case bot, user }
        let id = UUID()
        let role: Role
        let text: String
        let tag: String?
    }

    @State private var messages: [Message] = [
        .init(role: .bot,  text: "Hi there! I'm your AI mentor.\nHow can I help you today?", tag: "AI Mentor"),
        .init(role: .user, text: "I'd like some feedback on my recent presentation.", tag: "GIST"),
        .init(role: .bot,  text: "Sure, I can help with that. Please share the key points or a summary of your presentation.", tag: "AI Mentor")
    ]

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("AI Mentor")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.black)
                Spacer()
            }
            .padding(.vertical, 12)

            ScrollView {
                VStack(spacing: 0) {
                    botRow(name: messages[0].tag, text: messages[0].text)
                    userBlock(text: messages[1].text, tag: messages[1].tag)
                    botRow(name: messages[2].tag, text: messages[2].text)
                }
                .padding(.bottom, 12)
            }
            .background(Color.gray50.ignoresSafeArea())

            HStack {
                TextField("AI 멘토와 대화하세요.", text: $text)
                    .font(.callout)
                    .foregroundStyle(Color.gray600)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(Color.gray100)
                    )
                Button(action:{
                    
                }){
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.largeTitle)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .background(Color.gray50)
        .navigationBarTitleDisplayMode(.inline)
    }


    private func botRow(name: String?, text: String) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            Circle()
                .fill(Color.gray300)
                .frame(width: 28, height: 28)
                .overlay(Image(systemName: "person.crop.circle.fill")
                    .foregroundStyle(Color.gray700))
                .padding(.bottom, 2)

            VStack(alignment: .leading, spacing: 4) {
                if let name, !name.isEmpty {
                    Text(name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.gray500)
                }

                Text(text)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.black.opacity(0.85))
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 0.5)
                            )
                    )
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private func userBlock(text: String, tag: String?) -> some View {
        let avatarSize: CGFloat = 28
        let gap: CGFloat = 8
        let nameToBubbleGap: CGFloat = 4

        return VStack(alignment: .trailing, spacing: nameToBubbleGap) {
            if let tag, !tag.isEmpty {
                Text(tag)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.gray500)
                    .padding(.trailing, avatarSize + gap)
            }

            HStack(alignment: .bottom, spacing: gap) {
                Spacer(minLength: 0)

                Text(text)
                    .font(.system(size: 16))
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.violet500)
                    )

                Circle()
                    .fill(Color.orange400)
                    .frame(width: avatarSize, height: avatarSize)
                    .overlay(Image(systemName: "person.fill")
                        .foregroundStyle(Color.white))
                    .padding(.bottom, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

#Preview {
    NavigationView { ChatView() }
}
