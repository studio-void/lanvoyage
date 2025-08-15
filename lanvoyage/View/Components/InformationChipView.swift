//
//  Untitled.swift
//  lanvoyage
//
//  Created by Yeeun on 8/14/25.
//

import SwiftUI

// MARK: - Color Tokens (이 파일 전용)
private enum ChipTokens {
    // 기준 보라(primary) - 배경/테두리에 사용
    static let primary = Color(red: 0.47, green: 0.29, blue: 0.89)

    // 세 번째 칩(Outlined) 텍스트 컬러: #4C2CB5
    static let outlinedText = Color(red: 0.298, green: 0.173, blue: 0.709)

    // 네 번째 칩(Disabled) 텍스트 컬러: #9CA3AF
    static let disabledText = Color(red: 0.611, green: 0.639, blue: 0.686)

    // 공통 보더/배경
    static let plainStroke    = Color.black.opacity(0.15)
    static let disabledStroke = Color.black.opacity(0.12)
    static let disabledBG     = Color(.systemGray6)
}

// MARK: - Component
struct InformationChipButton: View {
    enum Kind {
        case plain
        case tinted
        case outlined
        case disabled
    }

    let title: String
    var kind: Kind = .plain
    var tint: Color = .gray
    var leadingIcon: String? = nil
    var action: () -> Void = {}

    // Layout
    private let hPad: CGFloat = 12
    private let vPad: CGFloat = 6
    private let corner: CGFloat = 8
    private let height: CGFloat = 32

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 6) {
                if let icon = leadingIcon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .frame(height: height, alignment: .center)
            .background(background)
            .cornerRadius(corner)
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .inset(by: 0.5)
                    .stroke(strokeColor, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(kind == .disabled)
        .contentShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }

    // MARK: - Style mapping
    private var foreground: Color {
        switch kind {
        case .plain:    return .primary
        case .tinted:   return tint
        case .outlined: return ChipTokens.outlinedText            // #4C2CB5
        case .disabled: return ChipTokens.disabledText            // #9CA3AF
        }
    }

    private var background: Color {
        switch kind {
        case .plain:    return .white
        case .tinted:   return tint.opacity(0.12)
        case .outlined: return ChipTokens.primary.opacity(0.12)   // 요구사항
        case .disabled: return ChipTokens.disabledBG
        }
    }

    private var strokeColor: Color {
        switch kind {
        case .plain:    return ChipTokens.plainStroke
        case .tinted:   return tint
        case .outlined: return ChipTokens.primary
        case .disabled: return ChipTokens.disabledStroke
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 14) {
        InformationChipButton(title: "회의", kind: .plain)

        InformationChipButton(title: "회의",
                              kind: .tinted,
                              tint: .mint)

        InformationChipButton(title: "회의",
                              kind: .outlined)

        InformationChipButton(title: "회의",
                              kind: .disabled)
    }
    .padding()
}
