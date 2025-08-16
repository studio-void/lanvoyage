//
//  WelcomeView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import SwiftUI
import VoidUtilities

struct WelcomeView: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack{
                    Spacer()
                    VStack{
                        Spacer()
                        Image("globalCommunication")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.7)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 32))
                            .padding(.bottom)
                        Text("Lan Voyage")
                            .font(.largeTitle)
                            .fontDesign(.monospaced)
                            .fontWeight(.semibold)
                            .padding(.bottom,8)
                        Text("Learning platform for global communication with AI literacy")
                            .font(.title3)
                            .foregroundStyle(Color.gray700)
                            .multilineTextAlignment(.center)
                        Spacer()
                        NavigationLink(destination: LanguageSelectionView().navigationBarBackButtonHidden(true)
                            .navigationBarTitleDisplayMode(.inline).navigationTitle("언어 설정")){
                            CustomButtonView(title: "바로 시작하기", kind: .filled)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }

        }
    }
}

#Preview {
    OnboardingMainView()
}
