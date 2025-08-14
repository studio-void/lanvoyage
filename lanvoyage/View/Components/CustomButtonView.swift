//
//  CustomButtonView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import SwiftUI
import VoidUtilities

struct CustomButtonView: View {
    enum Kind { case filled, outline, disabled }

    let title: String
    let kind: Kind
    var action: () -> Void = {}

    private let corner: CGFloat = 16
    private let brand: Color = Color.violet500

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 48)
                .padding(.horizontal, 8)
        }
        .buttonStyle(.plain)
        .foregroundStyle(foreground)
        .background(
            RoundedRectangle(cornerRadius: corner, style: .continuous)
                .fill(background)
        )
        .overlay(alignment: .center) {
            if kind == .outline {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(brand, lineWidth: 1)
            }
        }
        .opacity(kind == .disabled ? 1.0 : 1.0)
        .disabled(kind == .disabled)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 1, x: 0, y: 1)
    }

    private var foreground: Color {
        switch kind {
        case .filled:   return .white
        case .outline:  return brand
        case .disabled: return Color.gray.opacity(0.7)
        }
    }

    private var background: Color {
        switch kind {
        case .filled:   return brand
        case .outline:  return Color.white
        case .disabled: return Color.gray.opacity(0.35)
        }
    }
}

// MARK: - Preview Layout
struct CustomButtonsRow: View {
    let nextKind: CustomButtonView.Kind

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 16
            let w1 = (proxy.size.width - spacing) / 3          // "이전" 1/3
            let w2 = (proxy.size.width - spacing) * 2 / 3      // "다음" 2/3

            HStack(spacing: spacing) {
                CustomButtonView(title: "이전", kind: .outline) {}
                    .frame(width: w1)
                CustomButtonView(title: "다음", kind: nextKind) {}
                    .frame(width: w2)
            }
        }
        .frame(height: 64)
    }
}

#Preview("Buttons Layout") {
    HStack(spacing: 24) {
        // 왼쪽: outline + filled
        CustomButtonsRow(nextKind: .filled)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .padding()
    .background(Color(.secondarySystemBackground))
}
