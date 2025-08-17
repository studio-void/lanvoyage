//
//  TranslationChallengeManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import FirebaseAI
import Foundation

public struct TranslationChallengeSituation {
    var id = UUID()
    var role: Role
    var situation: String
    var questionSentence: String
    var expectedAnswer: String
}

public class TranslationChallengeManager {
    public func getSituation(role: Role) async throws
        -> TranslationChallengeSituation
    {
        print("TranslationChallengeManager.getSituation() requested.")
        let jsonSchema = Schema.object(
            properties: [
                "situation": .string(),
                "questionSentence": .string(),
                "expectedAnswer": .string(),
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
        var prompt = """
            You are in the app for language training, which focused on translation challenge with nuance. You are going to make situation, question sentence and expected answer. Consider situation that user might face as following prompt. You need to provide situation string in Korean, question sentence in English, and expected answer in English. Don't make simple situations, but you need to care the user level. User's current level is \(userLevel), while maximum is 20. User's point is \(userPoints), while maximum is 10000. The questionSentence and expectedAnswer should be in pair, and situation should completely describe the situation that user is facing and what user should answer. Also, situation is not the same as questionSentence. You need to describe the situation and what to say in virtual situation in 'situation', while you should provide the opposite speaker's question in 'questionSentence' and its expected answer in 'expectedAnswer'. <Role>\n
            """
        switch role {
        case .business:
            prompt +=
                "I am a businessman."
        case .student:
            prompt +=
                "I am a student."
        case .traveler:
            prompt +=
                "I am a traveler."
        }
        print(prompt)
        do {
            let response = try await model.generateContent(prompt)
            print(response)
            guard let text = response.text else {
                return TranslationChallengeSituation(
                    role: role,
                    situation: "Error parsing after fetching response.",
                    questionSentence: "Error parsing after fetching response.",
                    expectedAnswer: "Error parsing after fetching response."
                )
            }
            struct ResponseJSON: Decodable {
                let situation: String
                let questionSentence: String
                let expectedAnswer: String
            }
            let data = Data(text.utf8)
            do {
                let json = try JSONDecoder().decode(
                    ResponseJSON.self,
                    from: data
                )
                return TranslationChallengeSituation(
                    role: role,
                    situation: json.situation,
                    questionSentence: json.questionSentence,
                    expectedAnswer: json.expectedAnswer
                )
            } catch {
                return TranslationChallengeSituation(
                    role: role,
                    situation: "Error parsing response json.",
                    questionSentence: "Error parsing response json.",
                    expectedAnswer: "Error parsing response json."
                )
            }
        } catch {
            return TranslationChallengeSituation(
                role: role,
                situation: "Error fetching response.",
                questionSentence: "Error fetching response.",
                expectedAnswer: "Error fetching response."
            )
        }
    }
    
    public func gradeTranslation(_ translation: String, _ translationChallengeSituation: TranslationChallengeSituation) async throws -> (score: Int, description: String) {
        print("TranslationChallengeManager.gradeTranslation() requested.")
        let jsonSchema = Schema.object(
            properties: [
                "score": .integer(minimum: 0, maximum: 100),
                "description": .string()
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
        let prompt = """
            This is the audio file that user answered about the situation: "\(translationChallengeSituation.situation)".
            The user's role is '\(translationChallengeSituation.role)'.
            Mark user's answer score and write description about it in Korean. Don't give 100% easily, mark professionally. Output only the description to the 'description' field and mark the score to 'score' field. Also, please include how to fix it if the score is not high enough. You also need to care the user level. User's current level is \(userLevel), while maximum is 20. User's point is \(userPoints), while maximum is 10000. You expected the correct answer as '\(translationChallengeSituation.expectedAnswer)', for your information.
            """
        do {
            let response = try await model.generateContent(prompt)
            print(response)
            guard let text = response.text else {
                return (score: -1, description: "Failed to get response")
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
                return (score: json.score, description: json.description)
            } catch {
                return (score: -1, description: "Failed to parse response")
            }
        } catch {
            return (score: -1, description: "Failed to generate")
        }
    }
    
    public func gradeAudio(_ sentence: String, _ id: UUID) async throws -> (score: Int, description: String) {
        let arManager = AudioRecorderManager()
        let studyStyleManager = StudyStyleManager()
        let path = arManager.getDocumentsDirectory().appendingPathComponent(
            "\(id)_audio.m4a"
        )
        guard let audioData = try? Data(contentsOf: path) else {
            print("Error loading audio data.")
            return (score: -1, description: "Error loading audio data.")
        }
        let jsonSchema = Schema.object(
            properties: [
                "score": .integer(minimum: 0, maximum: 100),
                "description": .string()
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
        let prompt = """
            This is the audio file that user pronunciated for: '\(sentence)'
            Mark user's answer score and write description about it in Korean. Don't give 100% easily, mark professionally. Output only the description to the 'description' field and mark the score to 'score' field. Also, please include how to fix it if the score is not high enough. You also need to care the user level. User's current level is \(userLevel), while maximum is 20. User's point is \(userPoints), while maximum is 10000. Only care about the pronunciation and nuance. Don' care about its grammar or properness.
            """
        do {
            let response = try await model.generateContent(prompt)
            print(response)
            guard let text = response.text else {
                return (score: -1, description: "Failed to get response")
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
                return (score: json.score, description: json.description)
            } catch {
                return (score: -1, description: "Failed to parse response")
            }
        } catch {
            return (score: -1, description: "Failed to generate")
        }
    }
}
