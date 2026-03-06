import SwiftUI

@MainActor
private final class MissingSpeechRecognizerService: SpeechRecognizerServiceProtocol {
    var isRecording: Bool { false }

    func requestPermissions() async -> Bool {
        assertionFailure("speechRecognizerService environment value was not injected.")
        return false
    }

    func startRecording(
        localeIdentifier: String,
        onText: @escaping (String) -> Void,
        onFinish: @escaping () -> Void
    ) throws {
        assertionFailure("speechRecognizerService environment value was not injected.")
    }

    func stopRecording() {
        assertionFailure("speechRecognizerService environment value was not injected.")
    }

    func cancelRecording() {
        assertionFailure("speechRecognizerService environment value was not injected.")
    }
}

private struct SpeechRecognizerServiceKey: EnvironmentKey {
    static let defaultValue: any SpeechRecognizerServiceProtocol = MissingSpeechRecognizerService()
}

extension EnvironmentValues {
    var speechRecognizerService: any SpeechRecognizerServiceProtocol {
        get { self[SpeechRecognizerServiceKey.self] }
        set { self[SpeechRecognizerServiceKey.self] = newValue }
    }
}
