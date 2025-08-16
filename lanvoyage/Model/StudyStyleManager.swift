//
//  StudyStyleManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/14/25.
//

import Foundation

public enum StudyPurpose: String, CaseIterable {
    case studyAbroad = "유학/교환학생"
    case travel = "여행 회화"
    case business = "비즈니스/업무"
    case exam = "시험 대비"
    case immigration = "해외 이민/정착"
    case ai = "AI 활용 능력 강화"
}

public enum StudyStyle: String, CaseIterable {
    case shortFrequently = "짧고 자주"
    case longFocused = "길게 몰입"
    case grammarFocused = "문법 중심"
    case expressionFocused = "회화 중심"
    case aiToolsFocused = "AI 도구 활용"
    case examFocused = "시험 위주"
}

public enum TargetPeriod: String, CaseIterable {
    case twoWeeks = "2주"
    case oneMonth = "1개월"
    case threeMonths = "3개월"
    case sixMonths = "6개월"
    case oneYear = "1년"
}

public class StudyStyleManager {
    public let userDefaults = UserDefaults.standard
    public func setStudyPurpose(studyPurpose: StudyPurpose) {
        userDefaults.set(studyPurpose.rawValue, forKey: "studyPurpose")
    }
    public func setStudyStyle(studyStyle: StudyStyle) {
        userDefaults.set(studyStyle.rawValue, forKey: "studyStyle")
    }
    public func setTargetPeriod(targetPeriod: TargetPeriod) {
        userDefaults.set(targetPeriod.rawValue, forKey: "targetPeriod")
    }
    public func getStudyPurpose() -> StudyPurpose? {
        guard let studyPurposeString = userDefaults.string(forKey: "studyPurpose") else { return nil }
        return StudyPurpose(rawValue: studyPurposeString)
    }
    public func getStudyStyle() -> StudyStyle? {
        guard let studyStyleString = userDefaults.string(forKey: "studyStyle") else { return nil }
        return StudyStyle(rawValue: studyStyleString)
    }
    public func getTargetPeriod() -> TargetPeriod? {
        guard let targetPeriodString = userDefaults.string(forKey: "targetPeriod") else { return nil }
        return TargetPeriod(rawValue: targetPeriodString)
    }
}
