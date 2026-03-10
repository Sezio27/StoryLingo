import Foundation
import AVFoundation

@MainActor
final class AudioPlaybackService: NSObject, AudioPlaying {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    private let sampleRate: Double = 24_000
    private let channels: AVAudioChannelCount = 1

    private var didAttach = false
    private var isPlayingStream = false
    private var oneShotPlayer: AVAudioPlayer?

    override init() {
        super.init()
        setupEngineIfNeeded()
    }

    private func setupEngineIfNeeded() {
        guard !didAttach else { return }

        let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: true
        )!

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
        didAttach = true
    }

    private func activateSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
        try session.setActive(true)
    }

    func playAudio(data: Data) throws {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")

        try data.write(to: tempURL, options: .atomic)
        try playAudioFile(at: tempURL)
    }

    func playAudioFile(at url: URL) throws {
        stop()
        try activateSession()

        let player = try AVAudioPlayer(contentsOf: url)
        player.prepareToPlay()
        player.play()
        oneShotPlayer = player
    }

    func playPCMStream(_ stream: AsyncThrowingStream<Data, Error>) async throws {
        try activateSession()
        setupEngineIfNeeded()

        let format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: sampleRate,
            channels: channels,
            interleaved: true
        )!

        if engine.isRunning == false {
            try engine.start()
        }

        if playerNode.isPlaying == false {
            playerNode.play()
        }

        isPlayingStream = true
        defer { stop() }

        for try await chunk in stream {
            if Task.isCancelled || !isPlayingStream { break }
            if chunk.isEmpty { continue }

            guard let buffer = pcmBuffer(from: chunk, format: format) else { continue }
            playerNode.scheduleBuffer(buffer, completionHandler: nil)

            try await Task.sleep(nanoseconds: 20_000_000)
        }

        while playerNode.isPlaying && isPlayingStream {
            try await Task.sleep(nanoseconds: 50_000_000)
            if Task.isCancelled { break }
        }
    }

    func stop() {
        isPlayingStream = false
        playerNode.stop()
        engine.stop()

        oneShotPlayer?.stop()
        oneShotPlayer = nil
    }

    private func pcmBuffer(from data: Data, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let bytesPerFrame = 2 * Int(channels)
        let frameCount = data.count / bytesPerFrame
        guard frameCount > 0 else { return nil }

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: AVAudioFrameCount(frameCount)
        ) else {
            return nil
        }

        buffer.frameLength = AVAudioFrameCount(frameCount)

        data.withUnsafeBytes { rawBytes in
            guard let source = rawBytes.baseAddress else { return }
            if let dest = buffer.int16ChannelData?[0] {
                dest.assign(from: source.assumingMemoryBound(to: Int16.self), count: frameCount)
            }
        }

        return buffer
    }
}
