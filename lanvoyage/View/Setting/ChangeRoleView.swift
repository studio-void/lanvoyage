//
//  ChangeRoleView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import SwiftUI
import VoidUtilities

struct ChangeRoleView: View {
    @State private var selectedRole: Set<String> = []
    @State var studyStyleManager = StudyStyleManager()
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            HStack {
                Text("학습 목적 선택")
                Spacer()
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color.primary)
                }
            }
            .font(.title2)
            .fontWeight(.bold)
            .padding(.bottom, 8)
            HStack {
                Text("학습 목적/카테고리 및 역할을 누르면 자동으로 적용됩니다.")
                Spacer()
            }
            .foregroundStyle(Color.gray600)
            .padding(.bottom)
            LazyVGrid(columns: twoColumns, alignment: .center, spacing: 12) {
                ForEach(StudyPurpose.allCases, id: \.rawValue) { item in
                    SelectionChipView(
                        label: item.rawValue,
                        isSelected: Binding<Bool>(
                            get: { selectedRole.contains(item.rawValue) },
                            set: { isSelected in
                                if isSelected {
                                    selectedRole.insert(item.rawValue)
                                } else {
                                    selectedRole.remove(item.rawValue)
                                }
                            }
                        ),
                        tintColor: Color.violet500
                    )
                    .padding(.horizontal, 0.8)
                }
                .onChange(of: selectedRole) {
                    studyStyleManager.setStudyPurpose(
                        studyPurpose: selectedRole
                    )
                }
            }
            Spacer()

        }
    }
}

#Preview {
    ChangeRoleView()
}
