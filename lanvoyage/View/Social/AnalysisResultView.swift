//
//  AnalysisResultView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import SwiftUI
import VoidUtilities

struct AnalysisResultView: View {
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        ScrollView{
            HStack{
                Text("나의 학습 분석")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom,8)
            HStack{
                Text("마지막 학습: 2025. 08. 15.")
                    .foregroundStyle(Color.gray600)
                Spacer()
            }
            LazyVGrid(columns: columns) {
                AnalysisCardView(title: "정확도", mainNumber: 92, unit: "%", diffPercent: 5)
                AnalysisCardView(title: "학습 시간", mainNumber: 25, unit: "min", diffPercent: -10)
                AnalysisCardView(title: "포인트 획득", mainNumber: 1500, unit: "", diffPercent: 20)
                AnalysisCardView(title: "실력 향상 분야", mainNumber: 3, unit: "", diffPercent: -5)
            }
            HStack{
                Text("학습 경향 분석")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.bottom,4)
            HStack{
                Text("92%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom,4)
            HStack(alignment: .center){
                Text("지난 7일 대비")
                    .foregroundStyle(Color.gray500)
                Text("+5%")
                    .foregroundStyle(Color.green500)
                Spacer()
            }
        }
    }
}

private struct AnalysisCardView: View {
    var title: String
    var mainNumber: Int
    var unit: String
    var diffPercent: Int
    var body: some View {
        VStack(spacing: 16){
            HStack{
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            HStack{
                Text("\(mainNumber)\(unit)")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            HStack{
                Text("\(diffPercent)%")
                    .foregroundStyle(diffPercent>=0 ? Color.green500 : Color.red500)
                Spacer()
            }
        }
        .padding(28)
        .background(Color.gray100)
        .clipped()
        .cornerRadius(16)
        .padding(.bottom)
    }
}

#Preview {
    AnalysisResultView()
}
