//
//  ProfileView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI

private enum Token {
    static let card = Color.white
    static let text = Color.black.opacity(0.85)
    static let subtext = Color.black.opacity(0.5)
    static let border = Color(hex: "#DBE0E5")
    static let purple = Color(hex: "#8B5CF6")
    static let track = Color.black.opacity(0.1)
    static let radius: CGFloat = 12
}

struct ProfileView: View {
    @State private var title: String = "비즈니스 협상가"
    @State private var badges: Int = 15
    @State private var completed: Int = 3
    @State var userPointsManager = UserPointsManager()

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(spacing: 16) {
                        avatarBlock()
                        progressBlock()
                        overallBlock()
                    }
                }
                Spacer()
                NavigationLink(
                    destination: AnalysisResultView()
                        .navigationBarBackButtonHidden(true)
                ) {
                    CustomButtonView(title: "학습 분석 결과 보러가기", kind: .outline)
                }
            }
        }
    }

    private func avatarBlock() -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#CDD9FF"))
                    .frame(width: 120, height: 120)

                Image(systemName: "person.fill")
                    .resizable().scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.white)
            }

            Text("Level \(userPointsManager.getLevel())")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Token.text)

            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Token.subtext)

                Text("\(userPointsManager.getPoints()) XP")
                    .font(.footnote)
                    .foregroundStyle(Token.subtext)
            }
        }
    }

    // MARK: - Progress
    private func progressBlock() -> some View {
        // Pull data from the manager
        let currentPoints = userPointsManager.getPoints()
        let currentLevel = userPointsManager.getLevel()
        let bounds = userPointsManager.currentLevelBounds()
        let prev = bounds.prev
        let next = bounds.next
        let isMax = currentLevel >= 20 || next <= prev
        let progressValue: Double = isMax ? 1.0 : min(1.0, max(0.0, Double(currentPoints - prev) / Double(max(1, next - prev))))

        return VStack(spacing: 10) {
            // Top-right: current points only
            HStack {
                Spacer()
                Text("\(currentPoints) XP / \(bounds.next) XP")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Token.subtext)
            }

            // Progress bar based on next-level band
            ProgressBar(
                value: progressValue,
                height: 10,
                tint: Token.purple,
                track: Token.track
            )

            // Under the bar: left = previous level, right = next level (MAX if at cap)
            HStack {
                Text("Lv \(currentLevel)")
                    .font(.footnote)
                    .foregroundStyle(Token.subtext)
                Spacer()
                Text(isMax ? "MAX" : "Lv \(currentLevel + 1)")
                    .font(.footnote)
                    .foregroundStyle(Token.subtext)
            }
        }
    }

    // MARK: - Overall
    private func overallBlock() -> some View {
        VStack(spacing: 16) {
            Text("Overall Progress")
                .font(.headline)
                .foregroundStyle(Token.text)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16),
                ],
                spacing: 16
            ) {
                StatCard(title: "Points", value: "\(userPointsManager.getPoints())")
                StatCard(title: "Badges", value: "\(badges)")
            }

            StatCard(title: "Completed Courses", value: "\(completed)")
        }
    }
}

// MARK: - Components

struct ProgressBar: View {
    let value: Double
    let height: CGFloat
    let tint: Color
    let track: Color

    var body: some View {
        GeometryReader { geo in
            let w = max(0, min(value, 1)) * geo.size.width
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(track)
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(tint)
                    .frame(width: w)
            }
        }
        .frame(height: height)
        .animation(.easeOut(duration: 0.25), value: value)
    }
}

struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(Token.text)
            Text(title)
                .font(.footnote)
                .foregroundStyle(Token.subtext)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 92)
        .background(
            RoundedRectangle(cornerRadius: Token.radius)
                .fill(Token.card)
                .overlay(
                    RoundedRectangle(cornerRadius: Token.radius)
                        .stroke(Token.border, lineWidth: 1)
                )
        )
    }
}

// MARK: - Utilities
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ProfileView()
}
