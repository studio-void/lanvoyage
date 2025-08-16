//
//  MainView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/15/25.
//

import SwiftUI
import VoidUtilities

enum Tab {
    case home
    case learn
    case profile
    case chat
}

struct MainView: View {
    @State var selectedTab: Tab = .home
    var body: some View {
        VStack{
            switch selectedTab {
            case .home:
                HomeView()
                    .padding()
            case .learn:
                LearningMainView()
                    .padding()
            case .profile:
                ProfileView()
                    .padding()
            case .chat:
                ChattingMainView()
                    .padding()
            }
            Spacer()
            HStack{
                Spacer()
                VStack{
                    Image(systemName: selectedTab == .home ? "house.fill" : "house")
                        .font(.title3)
                    Text("Home")
                        .font(.subheadline)
                }
                .foregroundStyle(selectedTab == .home ? Color.violet500 : Color.gray600)
                .fontWeight(selectedTab == .home ? .semibold : .regular)
                .onTapGesture {
                    withAnimation {
                        selectedTab = .home
                    }
                }
                Spacer()
                VStack{
                    Image(systemName: selectedTab == .learn ? "graduationcap.fill" : "graduationcap")
                        .font(.title3)
                    Text("Learn")
                        .font(.subheadline)
                }
                .foregroundStyle(selectedTab == .learn ? Color.violet500 : Color.gray600)
                .fontWeight(selectedTab == .learn ? .semibold : .regular)
                .onTapGesture {
                    withAnimation {
                        selectedTab = .learn
                    }
                }
                Spacer()
                VStack{
                    Image(systemName: selectedTab == .profile ? "person.fill" : "person")
                        .font(.title3)
                    Text("Profile")
                        .font(.subheadline)
                }
                .foregroundStyle(selectedTab == .profile ? Color.violet500 : Color.gray600)
                .fontWeight(selectedTab == .profile ? .semibold : .regular)
                .onTapGesture {
                    withAnimation {
                        selectedTab = .profile
                    }
                }
                Spacer()
                VStack{
                    Image(systemName: selectedTab == .chat ? "bubble.fill" : "bubble")
                        .font(.title3)
                    Text("Chat")
                        .font(.subheadline)
                }
                .foregroundStyle(selectedTab == .chat ? Color.violet500 : Color.gray600)
                .fontWeight(selectedTab == .chat ? .semibold : .regular)
                .onTapGesture {
                    withAnimation {
                        selectedTab = .chat
                    }
                }
                Spacer()
            }
        }
    }
}

#Preview {
    MainView()
}
