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

public struct QuickResponseReturnType {
    var id: UUID
    var score: Int
    var description: String
}

public class QuickResponseChallengeManager {
    public func getSentence(role: Role) async throws -> String {
        print("getSentence requested")
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(modelName: "gemini-2.5-flash")
        let userPointsManager = UserPointsManager()
        let userPoints = userPointsManager.getPoints()
        let userLevel = userPointsManager.getLevel()
        var prompt: String =
            "You are in the app for language training, which focused on quick response challenge. You are going to make situations that user might facing as following prompt, and you are going to let user answer your question that user might face. Don't make simple questions, but you need to care the user level. User's current level is \(userLevel), while maximum is 20. User's point is \(userPoints), while maximum is 10000. Don't add others, and just print the single question, not with quotation mark or something. <Role and situation>\n"
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

    public func gradeResponse(data: QuickResponseData) async
        -> QuickResponseReturnType
    {
        let arManager = AudioRecorderManager()
        let studyStyleManager = StudyStyleManager()
        let id = data.id
        let path = arManager.getDocumentsDirectory().appendingPathComponent(
            "\(id)_audio.m4a"
        )
        guard let audioData = try? Data(contentsOf: path) else {
            print("Error loading audio data.")
            return QuickResponseReturnType(
                id: id,
                score: -1,
                description: "Error loading audio data."
            )
        }

        let jsonSchema = Schema.object(
            properties: [
                "score": .integer(),
                "description": .string(),
            ]
        )
        let ai = FirebaseAI.firebaseAI(backend: .googleAI())
        let model = ai.generativeModel(
            modelName: "gemini-2.5-flash",
            generationConfig: GenerationConfig(
                responseMIMEType: "application/json",
                responseSchema: jsonSchema
            )
        )
        
        let userPointsManager = UserPointsManager()
        let userPoints = userPointsManager.getPoints()
        let userLevel = userPointsManager.getLevel()

        let audio = InlineDataPart(data: audioData, mimeType: "audio/m4a")

        let prompt = """
            This is the audio file that user answered about the question: "\(data.sentence)".
            The user's role is '\(studyStyleManager.chooseRole())'.
            Mark user's score and write description about it in Korean. Don't give 100% easily, mark professionally as you need to care also about intonation, pronunciation and everything in the audio. Output only the description to the 'description' field and mark the score to 'score' field. Also, please include how to fix it if the score is not high enough. You also need to care the user level. User's current level is \(userLevel), while maximum is 20. User's point is \(userPoints), while maximum is 10000.
            """

        do {
            let response = try await model.generateContent(audio, prompt)
            print(response)
            guard let text = response.text else {
                return QuickResponseReturnType(
                    id: id,
                    score: -1,
                    description: "No response text."
                )
            }
            struct ResponseJSON: Decodable {
                let score: Int
                let description: String
            }
            let data = Data(text.utf8)
            do {
                let json = try JSONDecoder().decode(
                    ResponseJSON.self,
                    from: data
                )
                return QuickResponseReturnType(
                    id: id,
                    score: json.score,
                    description: json.description
                )
            } catch {
                return QuickResponseReturnType(
                    id: id,
                    score: -1,
                    description:
                        "Failed to decode response: \(error.localizedDescription)"
                )
            }
        } catch {
            return QuickResponseReturnType(
                id: id,
                score: -1,
                description:
                    "Error generating content: \(error.localizedDescription)"
            )
        }
    }
}
