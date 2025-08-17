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
    @AppStorage("userName") var userName: String = "GIST"

    var body: some View {
        NavigationView{
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
                    Text("\(userName)님, 환영합니다!")
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
                    NavigationLink(destination: QuickResponseChallengeView().navigationBarBackButtonHidden()) {
                        RecommendedLearningCardView(
                            image: Image("aiLearning"),
                            title: "Quick Response Challenge",
                            description:
                                "상황에 맞는 질의응답을 통해 언어 실력과 순발력을 향상시켜 보세요!"
                        )
                    }
                    NavigationLink(destination: TranslationChallengeView().navigationBarBackButtonHidden()) {
                        RecommendedLearningCardView(
                            image: Image("learningEnglish"),
                            title: "Translation Challenge",
                            description:
                                "주어진 상황에 맞는 대답을 영작한 후, 발음까지 테스트해 보세요!"
                        ) 
                    }
                    NavigationLink(destination: LearnModeView().navigationBarBackButtonHidden()) {
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
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.primary)
            Text(description)
                .foregroundStyle(Color.gray600)
                .multilineTextAlignment(.leading)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    MainView(selectedTab: .home)
}
