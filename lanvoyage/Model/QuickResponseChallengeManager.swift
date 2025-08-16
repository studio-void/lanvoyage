//
//  QuickResponseChallengeManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import FirebaseAI
import Foundation

public struct QuickResponseData {
    var id = UUID()
    var role: Role
    var sentence: String
}

public class QuickResponseChallengeManager {
    public func getSentence(role: Role) async throws -> String {
        print("getSentence requested")
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        var prompt: String =
            "You are in the app for language training, which focused on quick response challenge. You are going to make situations that user might facing as following prompt, and you are going to let user answer your question that user might face. Don't add others, and just print the single question, not with quotation mark or something. <Role and situation>\n"
        switch role {
        case .business:
            prompt +=
            "I am a businessman. Return a single sentence that a businessman might face in a real-world scenario. You need to give a single question that opposite speaker might say."
        case .student:
            prompt +=
            "I am a student. Return a single sentence that a student might face in a real-world scenario. You need to give a single question that opposite speaker might say."
        case .traveler:
            prompt +=
            "I am a traveler. Return a single sentence that a traveler might face in a real-world scenario. You need to give a single question that opposite speaker might say."
        }
        print(prompt)
        let response = try await model.generateContent(prompt)
        return response.text ?? "응답 생성 중 오류 발생"
    }
}
