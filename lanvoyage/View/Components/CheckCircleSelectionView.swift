//
//  CheckCircleSelectionView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct CheckCircleSelectionView: View {
    var label: String = ""
    @Binding var isSelected: Bool
    var tintColor: Color = .accentColor
    
    var body: some View {
        Button(action: {isSelected.toggle()}){
            HStack{
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? tintColor : Color.gray500)
                Text(label)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CheckCircleSelectionView(label: "2주", isSelected: .constant(false), tintColor: Color.violet500)
}
