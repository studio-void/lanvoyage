//
//  OnboardingMainView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct OnboardingMainView: View {
    @State var currentStep = 1
    @State var totalSteps = 2

    var body: some View {
        VStack {
            
            NavigationView {
                ChooseStudyPurposeView()
                    .navigationBarBackButtonHidden(true)
            }
            
            Spacer()

        }
        .padding()
    }
}

#Preview {
    OnboardingMainView()
}
