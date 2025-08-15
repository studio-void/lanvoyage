//
//  ChooseStudyStyleView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct ChooseStudyStyleView: View {
    @State var studyStyle: StudyStyle?
    @State private var selectedStyles: Set<String> = []
    @State var targetPeriod: TargetPeriod?
    @State private var selectedPeriod: Set<String> = []
    @Environment(\.presentationMode) var presentationMode

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        VStack {
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
            HStack {
                Text("어떤 학습 스타일이 편하신가요?")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 2)

            HStack {
                Text("중복 선택이 가능해요.")
                Spacer()

                Text("2/2")
                    .foregroundStyle(Color.gray500)
            }
            .foregroundStyle(Color.gray700)
            .padding(.bottom)
            LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                ForEach(StudyStyle.allCases, id: \.rawValue) { item in
                    SelectionChipView(
                        label: item.rawValue,
                        isSelected: Binding<Bool>(
                            get: { selectedStyles.contains(item.rawValue) },
                            set: { isSelected in
                                if isSelected {
                                    selectedStyles.insert(item.rawValue)
                                } else {
                                    selectedStyles.remove(item.rawValue)
                                }
                            }
                        ),
                        tintColor: Color.violet500
                    )
                    .padding(.horizontal, 0.8)
                }
                .onChange(of: selectedStyles) {
                    print("selectedStyles: \(selectedStyles)")
                }
            }
            .padding(.bottom)
            HStack {
                Text("목표 기간")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.bottom, 8)
            ForEach(TargetPeriod.allCases, id: \.rawValue) { item in
                HStack {
                    CheckCircleSelectionView(
                        label: item.rawValue,
                        isSelected: Binding<Bool>(
                            get: { selectedPeriod.contains(item.rawValue) },
                            set: { isSelected in
                                if isSelected {
                                    selectedPeriod.insert(item.rawValue)
                                } else {
                                    selectedPeriod.remove(item.rawValue)
                                }
                            }
                        ),
                        tintColor: Color.violet500
                    )
                    .scaleEffect(1.2, anchor: .leading)
                    .padding(.horizontal, 0.8)
                    Spacer()
                }
                .padding(.bottom, 2)
            }
            .onChange(of: selectedStyles) {
                print("selectedStyles: \(selectedStyles)")
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
                        CustomButtonView(title: "이전", kind: .outline)
                            .frame(width: w1)
                            .padding(.leading, 0.2)
                    }
                    NavigationLink(
                        destination: OnboardingCharacterView()
                            .navigationBarBackButtonHidden(true)
                    ) {
                        CustomButtonView(
                            title: "다음",
                            kind: (selectedStyles.isEmpty
                                || selectedPeriod.count != 1)
                                ? .disabled : .filled
                        )
                        .frame(width: w2)
                        .padding(.trailing, 0.2)
                    }.disabled(
                        selectedStyles.isEmpty || selectedPeriod.count != 1
                    )
                }
            }
            .frame(height: 49)
        }
    }
}

#Preview {
    ChooseStudyStyleView()
}
