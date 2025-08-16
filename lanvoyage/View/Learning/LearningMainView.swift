//
//  LearningMainView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI

struct LearningMainView: View {

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            Text("Learn")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color.fromHex("#121417"))
                .padding(.top, 20)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("카테고리")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.fromHex("#121417"))
                        .padding(.top, 16)

                    LearningSectionsView()
                        .padding(.top, 8)
                }
            }

            Spacer(minLength: 0)
        }
        .background(Color.clear)
    }
}

private struct LearningSectionsView: View {
    private let sections: [(String, String, String)] = [
        ("Translation Challenges", "Mastering Nuances", "Learn to navigate complex linguistic scenarios and cultural subtleties in translations."),
        ("Quick Response Speaking", "Instant Communication", "Enhance your ability to respond swiftly and effectively in real-time conversations."),
        ("AI Tool Mastery", "AI Integration", "Explore and master AI tools to streamline your communication and translation workflows.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            ForEach(sections.indices, id: \.self) { i in
                let s = sections[i]
                VStack(alignment: .leading, spacing: 4) {
                    Text(s.0)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.fromHex("#6B7280"))

                    Text(s.1)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color.fromHex("#121417"))

                    Text(s.2)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.fromHex("#6B7280"))
                }
            }
        }
    }
}

extension Color {
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(.sRGB,
                     red: Double(r) / 255,
                     green: Double(g) / 255,
                     blue: Double(b) / 255,
                     opacity: Double(a) / 255)
    }
}

#Preview {
    LearningMainView()
}
