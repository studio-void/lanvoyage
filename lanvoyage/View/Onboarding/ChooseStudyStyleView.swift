//
//  ChooseStudyStyleView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct ChooseStudyStyleView: View {
    var body: some View {
        VStack{
            HStack {
                VoidStepsView(
                    currentStep: 2,
                    totalSteps: 2,
                    tintColor: Color.violet500,
                    disabledOpacity: 0.3
                )
                Spacer()
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    OnboardingMainView()
}
