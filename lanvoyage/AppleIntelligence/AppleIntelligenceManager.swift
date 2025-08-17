//
//  AppleIntelligenceManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import Foundation
import FoundationModels
import SwiftUI
import Combine

@available(iOS 26.0, *)
class AppleIntelligenceManager: ObservableObject {
    private var session: LanguageModelSession?
    private var currentInstruction: String?
    @Published var isReady: Bool = false
    init() {
        Task {
            await initializeSession(withInstruction: nil)
        }
    }
    @MainActor
        func initializeSession(withInstruction instruction: String?) async {
            isReady = false
            self.session = nil
            self.currentInstruction = instruction
            let model = SystemLanguageModel.default
            print("Checking SystemLanguageModel availability...")
            switch model.availability {
            case .available:
                print("SystemLanguageModel is available. Initializing LanguageModelSession...")
                do {
                    if let instructionText = instruction, !instructionText.isEmpty {
                        self.session = LanguageModelSession(model: model, instructions: Instructions(instructionText))
                    } else {
                        self.session = LanguageModelSession(model: model)
                    }
                    print("LanguageModelSession initialized successfully.")
                    self.isReady = true
                } catch {
                    print("Failed to initialize LanguageModelSession: \(error.localizedDescription)")
                    if let genError = error as? LanguageModelSession.GenerationError {
                        print("Generation Error Context: \(genError.localizedDescription)")
                    }
                    self.isReady = false
                }
            case .unavailable(let reason):
                print("SystemLanguageModel is unavailable: \(reason)")
                print("Reason details: \(reason)")
                switch reason {
                case .deviceNotEligible:
                    print("Device is not eligible. Requires Apple Silicon (A17 Pro, A18, M1, M2, M3, M4 series chips).")
                case .appleIntelligenceNotEnabled:
                    print("Apple Intelligence is not enabled in system settings.")
                case .modelNotReady:
                    print("Model assets are not ready. They may be downloading or require more space.")
                @unknown default:
                    print("An unknown unavailability reason occurred.")
                }
                self.isReady = false
            }
        }
        func sendMessage(
            _ prompt: String,
            instruction: String? = nil,
            onNewToken: @escaping (String) -> Void,
            onComplete: @escaping (Result<String, Error>) -> Void
        ) {
            Task { @MainActor in
                if instruction != currentInstruction || session == nil || !isReady {
                    print("Instruction changed or session not ready. Re-initializing session...")
                    await initializeSession(withInstruction: instruction)
                }
                guard let currentSession = session, isReady else {
                    onComplete(.failure(NSError(domain: "ChatBotService", code: 1, userInfo: [NSLocalizedDescriptionKey: "LanguageModelSession is not initialized or not available after attempt."])))
                    return
                }
                do {
                    var fullResponse = ""
                    for try await chunk in currentSession.streamResponse(to: prompt) {
                        fullResponse += chunk
                        onNewToken(chunk)
                    }
                    onComplete(.success(fullResponse))
                } catch {
                    print("Error sending message: \(error.localizedDescription)")
                    if let genError = error as? LanguageModelSession.GenerationError {
                        print("Generation Error Type: \(genError)")
                        print("Recovery Suggestion: \(genError.recoverySuggestion ?? "None")")
                    }
                    onComplete(.failure(error))
                }
            }
        }
        @MainActor
        func startNewConversation() async {
            print("Starting a new conversation...")
            await initializeSession(withInstruction: nil)
        }
}
