//
//  AppleIntelligenceTestView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import SwiftUI
import FoundationModels

@available(iOS 26.0, *)
struct AppleIntelligenceTestView: View {
    @StateObject private var appleIntelligenceManager = AppleIntelligenceManager()
    @State private var inputText: String = ""
    @State private var chatHistory: [String] = []
    @State private var currentStreamedText: String = ""
    @State private var isLoading: Bool = false
    @State private var personaInstruction: String = "You are a helpful and concise assistant."
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(chatHistory, id: \.self) { message in
                        Text(message)
                            .padding(8)
                            .background(message.hasPrefix("You:") ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: message.hasPrefix("You:") ? .trailing : .leading)
                    }
                    if isLoading {
                        Text(currentStreamedText)
                            .padding(8)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            TextField("Set Assistant Persona (optional)", text: $personaInstruction)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .disabled(isLoading)
            HStack {
                TextField("Type your message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .disabled(isLoading)
                    .lineLimit(1...5)
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.isEmpty || isLoading || !appleIntelligenceManager.isReady)
                .padding(.vertical, 8)
            }
            .padding(.horizontal)
            Button("New Chat") {
                Task {
                    await appleIntelligenceManager.startNewConversation()
                    chatHistory.removeAll()
                    currentStreamedText = ""
                    inputText = ""
                }
            }
            .padding(.bottom)
            .disabled(isLoading)
        }
        .navigationTitle("Apple LLM Chat")
        .task {
            await appleIntelligenceManager.initializeSession(withInstruction: personaInstruction)
        }
    }
    private func sendMessage() {
        let userMessage = "You: \(inputText)"
        chatHistory.append(userMessage)
        isLoading = true
        currentStreamedText = "AI: "
        let promptToSend = inputText
        inputText = ""
        appleIntelligenceManager.sendMessage(
            promptToSend,
            instruction: personaInstruction,
            onNewToken: { chunk in
                DispatchQueue.main.async {
                    currentStreamedText += chunk
                }
            },
            onComplete: { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success(let fullResponse):
                        chatHistory.append("AI: \(fullResponse.replacingOccurrences(of: "AI: ", with: ""))")
                        currentStreamedText = ""
                    case .failure(let error):
                        chatHistory.append("Error: \(error.localizedDescription)")
                        currentStreamedText = ""
                    }
                }
            }
        )
    }
}

@available(iOS 26.0, *)
#Preview {
    AppleIntelligenceTestView()
}
