//
//  LangaugeSelectionView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import SwiftUI
import VoidUtilities

enum Language: String, CaseIterable, Identifiable {
    case korean = "한국어"
    case english = "English"
    case japanese = "日本語"
    case chinese = "中文"
    var id: Self { self }
}

struct LanguageSelectionView: View {
    @State var selectedPrimaryLanguage: Language = .korean
    @State var selectedTargetLanguage: Language = .english
    
    var body: some View {
        VStack{
            HStack{
                Text("기본 언어")
                    .fontWeight(.semibold)
                Spacer()
                Picker("기본 언어", selection: $selectedPrimaryLanguage) {
                    ForEach(Language.allCases) {
                        Text($0.rawValue)
                    }
                }
            }
            .padding()
            .background(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom)
            HStack{
                Text("배우고자 하는 언어")
                    .fontWeight(.semibold)
                Spacer()
                Picker("배우고자 하는 언어", selection: $selectedTargetLanguage) {
                    ForEach(Language.allCases) {
                        Text($0.rawValue)
                    }
                }
            }
            .padding()
            .background(Color.gray100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer()
            NavigationLink(destination: ChooseStudyPurposeView().navigationBarBackButtonHidden(true)) {
                CustomButtonView(title: "다음으로", kind: .filled)
            }
        }
    }
}

#Preview {
    LanguageSelectionView()
}
