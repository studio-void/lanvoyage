//
//  TranslationChallengeView.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/17/25.
//

import SwiftUI
import VoidUtilities

struct TranslationChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var studyStyleManager = StudyStyleManager()
    @State var translationChallengeManager = TranslationChallengeManager()
    @State var arManager = AudioRecorderManager()
    @State var userPointsManager = UserPointsManager()
    @State var translationChallengeSituation: TranslationChallengeSituation?
    @State var userAnswer: String = ""
    @State var isGeneratingSituation: Bool = false
    @State var isGradingUserAnswer: Bool = false
    @State var userAnswerPoint: Int?
    @State var userAnswerFeedback: String?
    @State var isRecording: Bool = false
    @State var recordDone: Bool = false
    @State var resultPath: String = ""
    @State var isPlaying: Bool = false
    @State var isGradingAudio: Bool = false
    @State var totalGradingDone: Bool = false
    @State var audioPoint: Int?
    @State var audioFeedback: String?
    @State var pointsAwardedForThisAttempt = false
    @State var currentStep = 1
    var body: some View {
        ScrollView {
            VStack {
                HStack(alignment: .center) {
                    Text("Translation Challenge")
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontDesign(.rounded)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() })
                    {
                        Image(systemName: "xmark")
                    }
                }
                .padding(.bottom, 8)
                HStack {
                    Text("주어지는 상황에 대한 응답을 영작한 후, 발음하세요.")
                        .foregroundStyle(Color.gray700)
                    Spacer()
                }
                .padding(.bottom)
                // MARK: - Step 1
                if currentStep >= 1 {
                    HStack {
                        Text("Step 1")
                        Spacer()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                    HStack {
                        Text(
                            "나의 역할인 \(studyStyleManager.chooseRole().rawValue)에 맞는 상황을 생성하세요."
                        )
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(Color.gray700)
                    .padding(.bottom, 8)
                    Button(action: {
                        withAnimation {
                            isGeneratingSituation = true
                        }
                        Task {
                            do {
                                translationChallengeSituation =
                                    try await translationChallengeManager
                                    .getSituation(
                                        role: studyStyleManager.chooseRole()
                                    )
                                withAnimation {
                                    currentStep += 1
                                }
                            } catch {
                                // Handle the error appropriately (for now, we'll just print it)
                                print("Failed to get situation: \(error)")
                            }
                            withAnimation {
                                isGeneratingSituation = false
                            }
                        }
                    }) {
                        CustomButtonView(
                            title: "상황 생성하기",
                            kind: (isGeneratingSituation || currentStep != 1)
                                ? .disabled : .filled
                        )
                    }
                    .disabled(isGeneratingSituation || currentStep != 1)
                    .padding(.bottom)
                    if isGeneratingSituation {
                        HStack {
                            ProgressView()
                            Text("상황을 생성하고 있어요. 잠시만 기다려 주세요...")
                        }
                    }
                }
                // MARK: - Step 2
                if currentStep >= 2 && translationChallengeSituation != nil {
                    HStack {
                        Text("Step 2")
                        Spacer()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                    HStack {
                        Text(
                            "주어진 상황에 맞는 문장을 뉘앙스를 고려하여 영작하세요."
                        )
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(Color.gray700)
                    .padding(.bottom, 8)
                    VStack {
                        HStack {
                            Text(translationChallengeSituation!.situation)
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        HStack {
                            Text(
                                translationChallengeSituation!.questionSentence
                            )
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color.violet100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    TextField("문장을 영작하세요.", text: $userAnswer)
                        .padding()
                        .background(Color.violet50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom)
                    Button(action: {
                        withAnimation {
                            isGradingUserAnswer = true
                        }
                        Task {
                            do {
                                (userAnswerPoint, userAnswerFeedback) =
                                    try await translationChallengeManager
                                    .gradeTranslation(
                                        userAnswer,
                                        translationChallengeSituation!
                                    )
                                withAnimation {
                                    currentStep += 1
                                }
                            } catch {
                                // Handle the error appropriately (for now, we'll just print it)
                                print("Failed to get situation: \(error)")
                            }
                            withAnimation {
                                isGradingUserAnswer = false
                            }
                        }
                    }) {
                        CustomButtonView(
                            title: "영작 제출하기",
                            kind: (isGradingUserAnswer || currentStep != 2)
                                ? .disabled : .filled
                        )
                    }
                    .disabled(isGradingUserAnswer || currentStep != 2)
                    .padding(.bottom)
                    if isGradingUserAnswer {
                        HStack {
                            ProgressView()
                            Text("영작을 채점하고 있어요. 잠시만 기다려 주세요...")
                        }
                    } else {
                        /*
                        if (userAnswerPoint != nil && userAnswerFeedback != nil) {
                            HStack {
                                Text("Step 2 - 영작 평가 결과")
                                Spacer()
                            }
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                            VStack{
                                HStack {
                                    Text(
                                        "\(userAnswerPoint!)점"
                                    )
                                    Spacer()
                                }
                                .font(.headline)
                                .foregroundStyle(Color.violet500)
                                .fontWeight(.semibold)
                                .padding(.bottom, 8)
                                HStack {
                                    Text(
                                        userAnswerFeedback!
                                    )
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(Color.violet50)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.bottom)
                        }
                         */
                    }
                }
                // MARK: - Step 3
                if currentStep >= 3 && translationChallengeSituation != nil
                    && userAnswerPoint != nil
                {
                    HStack {
                        Text("Step 3")
                        Spacer()
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.bottom, 4)
                    HStack {
                        Text(
                            "Step 2에서 대답한 '\(userAnswer)'을 직접 발음해 보세요."
                        )
                        Spacer()
                    }
                    .font(.callout)
                    .foregroundStyle(Color.gray700)
                    .padding(.bottom, 8)
                    HStack(spacing: 24) {
                        Button(action: {
                            if !isRecording {
                                let id = translationChallengeSituation!.id
                                resultPath = arManager.recordAudio(uuid: id)
                                print(
                                    "trying to save speaking audio data to path: \(resultPath)"
                                )
                                isRecording = true
                            } else {
                                arManager.stopRecording()
                                isGradingAudio = true
                                recordDone = true
                                isRecording = false
                                if isPlaying {
                                    arManager.stopAudio()
                                    isPlaying = false
                                }
                                Task {
                                    let id = translationChallengeSituation!.id
                                    let result =
                                        try await translationChallengeManager
                                        .gradeAudio(userAnswer, id)
                                    await MainActor.run {
                                        audioPoint = result.score
                                        audioFeedback = result.description
                                        if !pointsAwardedForThisAttempt {
                                            let audioScore = result.score
                                            let pointsToAdd =
                                                (audioScore + userAnswerPoint!)
                                                / 18
                                            userPointsManager.addPoints(
                                                pointsToAdd
                                            )
                                            pointsAwardedForThisAttempt = true
                                        }
                                        totalGradingDone = true
                                    }
                                    isGradingAudio = false
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
                        .disabled(isGradingAudio)
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
                    if isGradingAudio {
                        HStack {
                            ProgressView()
                            Text("발음를 채점하고 있어요. 잠시만 기다려 주세요...")
                        }
                    }
                    if totalGradingDone && userAnswerPoint != nil
                        && audioPoint != nil
                    {
                        VStack {
                            HStack {
                                Text(
                                    "영작: \(userAnswerPoint!)점"
                                )
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundStyle(Color.violet500)
                            .fontWeight(.semibold)
                            .padding(.bottom, 4)
                            HStack {
                                Text(
                                    "발음: \(audioPoint!)점"
                                )
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundStyle(Color.violet500)
                            .fontWeight(.semibold)
                            .padding(.bottom, 8)
                            HStack {
                                Text(
                                    "\(userAnswerFeedback!)\n\(audioFeedback!)"
                                )
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.violet50)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.bottom)
                        Button(action: {
                            currentStep = 1
                            userAnswer = ""
                            recordDone = false
                        }){
                            CustomButtonView(title: "다시하기", kind: .outline)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    TranslationChallengeView()
}
