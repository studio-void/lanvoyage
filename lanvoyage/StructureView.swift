//
//  StructureView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI

struct StructureView: View {
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    var body: some View {
        if isOnboardingCompleted {
            MainView()
        } else {
            OnboardingMainView()
        }
    }
}

#Preview {
    StructureView()
}
