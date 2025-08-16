//
//  AudioRecorderManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import AVFoundation

class AudioRecorderManager {
    func requestRecordPermission() -> Bool {
        var isGranted = false
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            isGranted = granted
        }
        return isGranted
    }

    func setupAudioSession() throws {
        if self.requestRecordPermission() {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
        }
    }

    var audioRecorder: AVAudioRecorder?

    func setupRecorder(uuid: UUID) throws {
        let recordingSettings =
            [
                AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ] as [String: Any]
        let documentPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]
        // Audio will be saved as .caf format for compatibility
        let audioFilename = documentPath.appendingPathComponent(uuid.uuidString+"_audio.caf")
        print("Set up recorder for saving to \(audioFilename)..")

        audioRecorder = try AVAudioRecorder(
            url: audioFilename,
            settings: recordingSettings
        )
        audioRecorder?.prepareToRecord()
    }

    func startRecording() {
        audioRecorder?.record()
    }
    
    func recordAudio(uuid: UUID) -> String {
        do {
            try self.setupAudioSession()
            try self.setupRecorder(uuid: uuid)
            self.startRecording()
            if let audioURL = audioRecorder?.url {
                // The returned audio path always ends with .caf
                return audioURL.path
            } else {
                return "Audio path fetching failed!"
            }
        } catch {
            print("Error setting up audio session: \(error)")
            return "Audio recording failed!"
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
    }
    
    func playAudio(url: URL) {
        // This expects a .caf format file for compatibility
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
}
