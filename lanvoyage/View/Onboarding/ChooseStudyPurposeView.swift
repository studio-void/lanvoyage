//
//  ChooseStudyPurposeView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct ChooseStudyPurposeView: View {
    @State var studyPurpose: StudyPurpose?
    @State private var selected: Set<String> = []
    @Environment(\.presentationMode) var presentationMode

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack {
            HStack {
                VoidStepsView(
                    currentStep: 1,
                    totalSteps: 2,
                    tintColor: Color.violet500,
                    disabledOpacity: 0.3
                )
                Spacer()
            }
            .padding(.bottom, 8)
            HStack {
                Text("학습 목적을 알려주세요.")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 2)

            HStack {
                Text("가장 가까운 항목을 한 개 선택해 주세요.")
                Spacer()

                Text("1/2")
                    .foregroundStyle(Color.gray500)
            }
            .foregroundStyle(Color.gray700)
            .padding(.bottom)
            LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                ForEach(StudyPurpose.allCases, id: \.rawValue) { item in
                    SelectionChipView(
                        label: item.rawValue,
                        isSelected: Binding<Bool>(
                            get: { selected.contains(item.rawValue) },
                            set: { isSelected in
                                if isSelected {
                                    selected.insert(item.rawValue)
                                } else {
                                    selected.remove(item.rawValue)
                                }
                            }
                        ),
                        tintColor: Color.violet500
                    )
                    .padding(.horizontal, 0.8)
                }
                .onChange(of: selected) {
                    print("selected: \(selected)")
                }
            }
            Spacer()
            GeometryReader { proxy in
                let spacing: CGFloat = 12
                let w1 = (proxy.size.width - spacing) / 3  // "이전" 1/3
                let w2 = (proxy.size.width - spacing) * 2 / 3  // "다음" 2/3

                HStack(spacing: spacing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        CustomButtonView(title: "이전", kind: .outline) {}
                            .frame(width: w1)
                            .padding(.leading, 0.2)
                    }
                    NavigationLink(
                        destination: ChooseStudyStyleView()
                            .navigationBarBackButtonHidden(true)
                    ) {
                        CustomButtonView(
                            title: "다음",
                            kind: (selected.count != 1) ? .disabled : .filled
                        ) {}
                        .frame(width: w2)
                        .padding(.trailing, 0.2)
                    }.disabled(selected.count != 1)
                }
            }
            .frame(height: 49)
        }
    }
}

#Preview {
    //    ChooseStudyPurposeView()
    OnboardingMainView()
}
