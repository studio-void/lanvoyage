//
//  StudyStyleManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import Foundation

enum StudyPurpose: String, CaseIterable {
    case studyAbroad = "유학/교환학생"
    case travel = "여행 회화"
    case business = "비즈니스/업무"
    case exam = "시험 대비"
    case immigration = "해외 이민/정착"
    case ai = "AI 활용 능력 강화"
}

enum StudyStyle: String, CaseIterable {
    case shortFrequently = "짧고 자주"
    case longFocused = "길게 몰입"
    case grammarFocused = "문법 중심"
    case expressionFocused = "회화 중심"
    case aiToolsFocused = "AI 도구 활용"
    case examFocused = "시험 위주"
}

enum TargetPeriod: String, CaseIterable {
    case twoWeeks = "2주"
    case oneMonth = "1개월"
    case threeMonths = "3개월"
    case sixMonths = "6개월"
    case oneYear = "1년"
}

class StudyStyleManager {
    
}
