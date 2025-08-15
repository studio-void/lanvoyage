//
//  ProfileView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI

private enum Token {
    static let card     = Color.white
    static let text     = Color.black.opacity(0.85)
    static let subtext  = Color.black.opacity(0.5)
    static let border   = Color(hex: "#DBE0E5")
    static let purple   = Color(hex: "#8B5CF6")
    static let track    = Color.black.opacity(0.1)
    static let radius: CGFloat = 12
}

struct ProfileTabRoot: View {
    @State private var selection = 2

    var body: some View {
        TabView(selection: $selection) {
            Text("Home")
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            Text("Learn")
                .tabItem { Label("Learn", systemImage: "graduationcap.fill") }
                .tag(1)

            NavigationStack {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.fill") }
            .tag(2)

            Text("Chat")
                .tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right.fill") }
                .tag(3)
        }
    }
}

struct ProfileView: View {
    @State private var level: Int = 3
    @State private var title: String = "비즈니스 협상가"
    @State private var xp: Double = 1200
    @State private var xpMax: Double = 2000
    @State private var points: Int = 1200
    @State private var badges: Int = 15
    @State private var completed: Int = 3

    var progress: Double { xp / xpMax }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                avatarBlock()
                progressBlock()
                overallBlock()
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
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

            Text("Level \(level)")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Token.text)

            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Token.subtext)

                Text("\(Int(xp))/\(Int(xpMax)) XP")
                    .font(.footnote)
                    .foregroundStyle(Token.subtext)
            }
        }
    }

    // MARK: - Progress
    private func progressBlock() -> some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Token.subtext)
            }

            ProgressBar(value: progress, height: 10, tint: Token.purple, track: Token.track)
        }
    }

    // MARK: - Overall
    private func overallBlock() -> some View {
        VStack(spacing: 16) {
            Text("Overall Progress")
                .font(.headline)
                .foregroundStyle(Token.text)
                .frame(maxWidth: .infinity, alignment: .center)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                StatCard(title: "Points", value: "\(points)")
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
                RoundedRectangle(cornerRadius: height/2)
                    .fill(track)
                RoundedRectangle(cornerRadius: height/2)
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
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

#Preview {
    ProfileTabRoot()
}
