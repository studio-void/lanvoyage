//
//  QuickResponseChallengeView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import SwiftUI
import VoidUtilities
import AlertToast

struct QuickResponseChallengeView: View {
    @State var quickResponseData: QuickResponseData?
    @State var arManager = AudioRecorderManager()
    @State var studyStyleManager = StudyStyleManager()
    @State var quickResponseChallengeManager = QuickResponseChallengeManager()
    @State var quickResponseReturn: QuickResponseReturnType?
    @State var userPointsManager = UserPointsManager()
    @State var resultPath = ""
    @State var questionSentence: String?
    @State var answerSentence: String?
    @State var isGenerating: Bool = false
    @State var isRecording: Bool = false
    @State var recordDone: Bool = false
    @State var generatingAvailable: Bool = true
    @State var isGrading: Bool = false
    @State var gradingDone: Bool = false
    @State var isPlaying = false
    @State var awardedPoints = 0
    @State var showToast = false
    @State var timer: Timer?
    @State var elapsedSeconds: Int = 0
    @State private var pointsAwardedForThisAttempt: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var timerString: String {
        String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60)
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {
            _ in
            elapsedSeconds += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func computePoints(score: Int, elapsed: Int) -> Int {
        // Base: score/10, Time bonus: every 20s saved up to 60s
        let base = max(0, score / 10)
        let timeBonus = max(0, (60 - elapsed) / 20)
        return base + timeBonus
    }

    var body: some View {
        ScrollView{
            VStack {
                HStack(alignment: .center) {
                    Text("Quick Response Challenge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    Spacer()
                    Button(action:{presentationMode.wrappedValue.dismiss()}){
                        Image(systemName: "xmark")
                    }
                }
                .padding(.bottom, 8)
                HStack {
                    Text("주어지는 문장에 대해 빠르게 응답하세요.")
                        .foregroundStyle(Color.gray700)
                    Spacer()
                }
                .padding(.bottom)
                VStack {
                    switch studyStyleManager.chooseRole() {
                    case .business:
                        HStack {
                            Image(systemName: "suitcase.fill")
                            Text("나의 역할: 비즈니스")
                            Spacer()
                        }
                        .foregroundStyle(Color.violet500)
                        .fontWeight(.semibold)
                    case .traveler:
                        HStack {
                            Image(systemName: "airplane.departure")
                            Text("나의 역할: 여행자")
                            Spacer()
                        }
                        .foregroundStyle(Color.violet500)
                        .fontWeight(.semibold)
                    case .student:
                        HStack {
                            Image(systemName: "graduationcap.fill")
                            Text("나의 역할: 학생")
                            Spacer()
                        }
                        .foregroundStyle(Color.violet500)
                        .fontWeight(.semibold)
                    }
                    HStack {
                        Text("당신이 경험할 만한 상황에서 질문을 출제합니다.")
                        Spacer()
                    }
                    .foregroundStyle(Color.gray600)
                    .padding(.top, 8)
                    .padding(.bottom)
                    HStack {
                        Button(action: {
                            Task {
                                do {
                                    print("AI requested")
                                    isGenerating = true
                                    let role = studyStyleManager.chooseRole()
                                    questionSentence =
                                    try await quickResponseChallengeManager
                                        .getSentence(role: role)
                                    isGenerating = false
                                    generatingAvailable = false
                                    elapsedSeconds = 0
                                    startTimer()
                                } catch {
                                    // Optionally handle or log the error
                                    questionSentence = nil
                                    isGenerating = false
                                }
                            }
                        }) {
                            CustomButtonView(
                                title: "문장 생성하기",
                                kind: generatingAvailable ? .outline : .disabled
                            )
                        }
                        .disabled(!generatingAvailable)
                    }
                }
                .padding()
                .background(Color.violet100)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                if isGenerating {
                    ProgressView()
                } else if let question = questionSentence {
                    VStack(spacing: 8) {
                        HStack {
                            Spacer()
                            Text(question)
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.violet900)
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                        .background(Color.violet50)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.bottom)
                        HStack(spacing: 4) {
                            Image(systemName: "timer")
                                .foregroundStyle(Color.violet500)
                            Text(timerString)
                                .font(.headline)
                                .monospacedDigit()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                    HStack(spacing: 24) {
                        Button(action: {
                            if !isRecording {
                                let newData = QuickResponseData(
                                    role: studyStyleManager.chooseRole(),
                                    sentence: questionSentence!
                                )
                                resultPath = arManager.recordAudio(
                                    uuid: newData.id
                                )
                                print(
                                    "trying to save speaking audio data to path: \(resultPath)"
                                )
                                quickResponseData = newData
                                isRecording = true
                                pointsAwardedForThisAttempt = false
                            } else {
                                arManager.stopRecording()
                                stopTimer()
                                isRecording = false
                                recordDone = true
                                // Stop any playing audio as well when recording stops
                                if isPlaying {
                                    arManager.stopAudio()
                                    isPlaying = false
                                }
                                let elapsedAtStop = elapsedSeconds
                                Task {
                                    let result = await quickResponseChallengeManager.gradeResponse(data: quickResponseData!)
                                    await MainActor.run {
                                        self.quickResponseReturn = result
                                        if !pointsAwardedForThisAttempt {
                                            let score = result.score
                                            let pointsToAdd = computePoints(score: score, elapsed: elapsedAtStop)
                                            awardedPoints = pointsToAdd
                                            userPointsManager.addPoints(pointsToAdd)
                                            pointsAwardedForThisAttempt = true
                                            showToast = true
                                        }
                                        gradingDone = true
                                        generatingAvailable = true
                                    }
                                }
                            }
                        }) {
                            Image(
                                systemName: isRecording
                                ? "stop.circle.fill"
                                : "microphone.circle.fill"
                            )
                            .font(.system(size: 96))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.pink500, Color.blue500],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        }
                        if recordDone {
                            Button(action: {
                                if !isPlaying {
                                    if let url = URL(string: resultPath),
                                       url.isFileURL
                                    {
                                        arManager.playAudio(url: url)
                                    } else {
                                        arManager.playAudio(
                                            url: URL(
                                                fileURLWithPath: resultPath
                                            )
                                        )
                                    }
                                    isPlaying = true
                                } else {
                                    arManager.stopAudio()
                                    isPlaying = false
                                }
                            }) {
                                Image(
                                    systemName: isPlaying
                                    ? "stop.circle.fill"
                                    : "play.circle.fill"
                                )
                                .font(.system(size: 96))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.pink500, Color.blue500],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                        }
                    }
                    .padding(.bottom)
                    if isGrading {
                        Text("분석중..")
                    } else {
                        if gradingDone {
                            if quickResponseReturn != nil {
                                VStack{
                                    HStack{
                                        Text("\(String(describing: quickResponseReturn!.score))점")
                                        Spacer()
                                    }
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.violet700)
                                    HStack{
                                        Text("\(String(describing: quickResponseReturn!.description))")
                                        Spacer()
                                    }
                                    .foregroundStyle(Color.violet500)
                                }
                                .padding()
                                .background(Color.violet100)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                Spacer()
            }
            .onDisappear {
                stopTimer()
                if isPlaying {
                    arManager.stopAudio()
                    isPlaying = false
                }
            }
        }
        .toast(isPresenting: $showToast, duration: 5, tapToDismiss: true) {
            AlertToast(displayMode: .hud, type: .systemImage("p.circle.fill", Color.violet500), title: "+\(awardedPoints) XP", subTitle: "XP Granted")
        } completion: {
            showToast = false
        }
    }
}

#Preview {
    QuickResponseChallengeView()
}
