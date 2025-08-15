//
//  HomeView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI
import VoidUtilities

struct HomeView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ScrollView {
            //            HStack{
            //                Spacer()
            //                Text("Home")
            //                    .font(.title3)
            //                    .fontWeight(.semibold)
            //                Spacer()
            //            }
            //            .padding(.bottom)
            HStack {
                Text("GIST님, 환영합니다!")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 6)
            HStack {
                Text("Lan Voyage와 함께 학습 여정을 떠나 보세요!")
                    .foregroundStyle(Color.gray700)
                Spacer()
            }
            .padding(.bottom)
            HStack {
                Text("추천 학습")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            LazyVGrid(columns: columns, alignment: .leading) {
                RecommendedLearningCardView(
                    image: Image("aiLearning"),
                    title: "AI Ethics and Bias",
                    description:
                        "Understand the ethical implications of AI and how to identify biases."
                )
                RecommendedLearningCardView(
                    image: Image("learningEnglish"),
                    title: "AI in Everyday Life",
                    description:
                        "Explore how AI is integrated into daily routines and its impact."
                )
                RecommendedLearningCardView(
                    image: Image("aiToolsExploration"),
                    title: "AI Tools Exploration",
                    description:
                        "Discover and experiment with various AI tools and applications."
                )
            }
        }
    }
}

struct RecommendedLearningCardView: View {
    var image: Image
    var title: String
    var description: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            image
                .resizable()
                .scaledToFit()
                .cornerRadius(16)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Text(description)
                .foregroundStyle(Color.gray600)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    MainView(selectedTab: .home)
}
