//
//  AudioRecorderManager.swift
//  lanvoyage
//
//  Created by 임정훈 on 8/16/25.
//

import AVFoundation

class AudioRecorderManager: NSObject, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    func requestRecordPermission() -> Bool {
        var isGranted = false
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            isGranted = granted
        }
        return isGranted
    }

    func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    }

    func setupPlaybackSession() throws {
        let s = AVAudioSession.sharedInstance()
        try s.setActive(false)
        try s.setCategory(.playback, mode: .default)
        try s.setActive(true)
    }

    func getDocumentsDirectory() -> URL {
        let urlList = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return urlList.first!
    }

    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    func setupRecorder(uuid: UUID) throws {
        let recordingSettings =
            [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
            ] as [String: Any]
        print(recordingSettings)
//        let documentPath = FileManager.default.urls(
//            for: .documentDirectory,
//            in: .userDomainMask
//        )[0]
        let audioFileName = getDocumentsDirectory().appendingPathComponent("\(uuid)_audio.m4a")
        // Audio will be saved as .caf format for compatibility
//        let audioFilename = documentPath.appendingPathComponent(
//            uuid.uuidString + "_audio.caf"
//        )
        print("Set up recorder for saving to \(audioFileName)..")

        audioRecorder = try AVAudioRecorder(
            url: audioFileName,
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
                // The returned audio path ends with .m4a
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
        audioRecorder = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func logCurrentRoute(_ prefix: String = "route") {
        let r = AVAudioSession.sharedInstance().currentRoute
        let outs = r.outputs.map { "\($0.portType.rawValue)" }.joined(separator: ", ")
        let ins  = r.inputs.map { "\($0.portType.rawValue)" }.joined(separator: ", ")
        print("[\(prefix)] inputs=\(ins) outputs=\(outs)")
    }

    func playAudio(url: URL) {
        // This expects a .m4a (AAC) file saved by our recorder
        // Sanity checks for file existence and non-empty data
        let path = url.path
        if !FileManager.default.fileExists(atPath: path) {
            print("Audio file does not exist at path: \(path)")
            return
        }
        if let attr = try? FileManager.default.attributesOfItem(atPath: path),
           let size = attr[.size] as? NSNumber, size.intValue == 0 {
            print("Audio file is empty at path: \(path)")
            return
        }
        do {
            try setupPlaybackSession()
            logCurrentRoute("before-play")
            print("trying to play: \(url)...")
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.numberOfLoops = 0
            audioPlayer?.volume = 1.0
            if audioPlayer?.prepareToPlay() == false {
                print("prepareToPlay() returned false")
            }
            print("duration=", audioPlayer?.duration ?? -1, "current=", audioPlayer?.currentTime ?? -1)
            let ok = audioPlayer?.play() ?? false
            print("play() -> \(ok), isPlaying=\(audioPlayer?.isPlaying ?? false)")
            logCurrentRoute("after-play")
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    func stopAudio() {
        audioPlayer?.pause()
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("audioPlayerDecodeErrorDidOccur: \(String(describing: error))")
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying: successfully=\(flag)")
    }
}
