//
//  SettingMainView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import SwiftUI
import VoidUtilities

struct SettingMainView: View {
    var appVersion: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return nil }
        return version
    }
    
    var buildCode: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleVersion"] as? String else { return nil }
        return version
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("설정")
                    Spacer()
                }
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
                HStack {
                    Text("사용자 설정")
                    Spacer()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom,8)
                NavigationLink(destination: ChangeRoleView().navigationBarBackButtonHidden()) {
                    HStack{
                        Text("학습 카테고리/역할 설정")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(Color.violet500)
                    .padding()
                    .background(Color.violet200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.bottom)
                HStack {
                    Text("정보")
                    Spacer()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom,8)
                HStack{
                    Text("앱 버전")
                    Spacer()
                    Text("v\(appVersion!) (\(buildCode!))")
                        .foregroundStyle(Color.gray600)
                }
                .padding(.bottom,8)
                HStack{
                    Text("개발자")
                    Spacer()
                    Text("Studio VO!D")
                        .foregroundStyle(Color.gray600)
                }
                .padding(.bottom,8)
            }
        }
    }
}

#Preview {
    SettingMainView()
}
