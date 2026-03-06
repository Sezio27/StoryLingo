//
//  SpeechRecognizerService.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation
import Speech
import AVFoundation

@MainActor
protocol SpeechRecognizerServiceProtocol: AnyObject {
    var isRecording: Bool { get }
    func requestPermissions() async -> Bool
    func startRecording(
        localeIdentifier: String,
        onText: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) throws
    func stopRecording()
}

@MainActor
final class SpeechRecognizerService: NSObject, SpeechRecognizerServiceProtocol {
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var stopTask: Task<Void, Never>?

    private(set) var isRecording = false

    func requestPermissions() async -> Bool {
        let speechAuthorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        let micAuthorized = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }

        return speechAuthorized && micAuthorized
    }

    func startRecording(
        localeIdentifier: String,
        onText: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) throws {
        stopRecording()

        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)),
              recognizer.isAvailable else {
            throw NSError(
                domain: "SpeechRecognizerService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Speech recognition is unavailable for this language."]
            )
        }

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        if #available(iOS 16, *) {
            request.addsPunctuation = false
        }
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        isRecording = true

        recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }

            if let result {
                onText(result.bestTranscription.formattedString)

                if result.isFinal {
                    self.stopRecording()
                    onFinish()
                }
            }

            if error != nil {
                self.stopRecording()
                onFinish()
            }
        }

        stopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 8_000_000_000)
            guard let self, self.isRecording else { return }
            self.stopRecording()
            onFinish()
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        stopTask?.cancel()
        stopTask = nil

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        isRecording = false
    }

    deinit {
        stopTask?.cancel()
    }
}
