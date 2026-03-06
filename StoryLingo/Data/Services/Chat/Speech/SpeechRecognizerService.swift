import Foundation
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
    func cancelRecording()
}

@MainActor
final class SpeechRecognizerService: NSObject, SpeechRecognizerServiceProtocol {
    private let transcriber: AudioTranscribing
    private var recorder: AVAudioRecorder?
    private var stopTask: Task<Void, Never>?
    private var onText: ((String) -> Void)?
    private var onFinish: (() -> Void)?
    private var localeIdentifier: String?
    private var currentRecordingURL: URL?
    private let maxRecordingSeconds: Double = 15
    private var shouldTranscribeAfterStop = true
    
    private(set) var isRecording = false

    init(transcriber: AudioTranscribing) {
        self.transcriber = transcriber
        super.init()
    }

    func requestPermissions() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording(
        localeIdentifier: String,
        onText: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) throws {
        stopRecording()

        self.onText = onText
        self.onFinish = onFinish
        self.localeIdentifier = localeIdentifier
        self.shouldTranscribeAfterStop = true

        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .spokenAudio, options: [.duckOthers])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 16_000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.prepareToRecord()
        recorder.record()

        self.recorder = recorder
        self.currentRecordingURL = url
        self.isRecording = true

        stopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(maxRecordingSeconds * 1_000_000_000))
            guard let self, self.isRecording else { return }
            await self.finishRecordingAndTranscribe()
        }
    }

    func stopRecording() {
        guard isRecording else { return }
        Task { await finishRecordingAndTranscribe() }
    }
    
    func cancelRecording() {
        guard isRecording else { return }

        shouldTranscribeAfterStop = false
        stopTask?.cancel()
        stopTask = nil

        recorder?.stop()
        let fileURL = currentRecordingURL

        recorder = nil
        currentRecordingURL = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        if let fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }

        onText = nil
        onFinish = nil
    }

    private func finishRecordingAndTranscribe() async {
        guard isRecording else { return }

        stopTask?.cancel()
        stopTask = nil

        recorder?.stop()
        let fileURL = currentRecordingURL

        recorder = nil
        currentRecordingURL = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        guard shouldTranscribeAfterStop else {
            if let fileURL {
                try? FileManager.default.removeItem(at: fileURL)
            }
            onText = nil
            onFinish = nil
            shouldTranscribeAfterStop = true
            return
        }

        guard let fileURL else {
            onFinish?()
            return
        }

        do {
            let languageCode = localeLanguageCode(from: localeIdentifier)
            let transcript = try await transcriber.transcribeAudio(
                fileURL: fileURL,
                language: languageCode
            )

            onText?(transcript)
        } catch {
            print("Transcription error:", error)
        }

        onFinish?()

        try? FileManager.default.removeItem(at: fileURL)
        onText = nil
        onFinish = nil
        shouldTranscribeAfterStop = true
    }

    private func localeLanguageCode(from localeIdentifier: String?) -> String? {
        guard let localeIdentifier else { return nil }
        return localeIdentifier.split(separator: "-").first.map(String.init)
    }

    deinit {
        stopTask?.cancel()
    }
}
