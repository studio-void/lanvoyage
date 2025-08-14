//
//  SelectionChip.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI

struct SelectionChipView: View {
    let label: String
    @Binding var isSelected: Bool
    var tintColor: Color = .accentColor

    private let cornerRadius: CGFloat = 14

    init(label: String, isSelected: Binding<Bool>, tintColor: Color = .accentColor) {
        self.label = label
        self._isSelected = isSelected
        self.tintColor = tintColor
    }

    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(minHeight: 44)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? tintColor : Color.primary)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(isSelected ? tintColor.opacity(0.08) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(isSelected ? tintColor : Color.black.opacity(0.15), lineWidth: isSelected ? 2 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .animation(.snappy(duration: 0.15), value: isSelected)
        .shadow(color: Color.black.opacity(0.02), radius: 1.5, x: 0, y: 1)
    }
}

// MARK: - Demo grid usage for previews / reference
private struct ChipGridPreview: View {
    @State private var selected: Set<String> = ["시험 대비"]

    private let items = [
        "유학 / 교환학생",
        "여행 회화",
        "비즈니스 / 업무",
        "시험 대비",
        "해외 이민 / 정착",
        "AI 활용 능력 강화"
    ]

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                ForEach(items, id: \ .self) { label in
                    SelectionChipView(
                        label: label,
                        isSelected: Binding(
                            get: { selected.contains(label) },
                            set: { newValue in
                                if newValue { selected.insert(label) } else { selected.remove(label) }
                            }
                        ),
                        tintColor: .purple
                    )
                }
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
    }
}

#Preview {
    ChipGridPreview()
}
