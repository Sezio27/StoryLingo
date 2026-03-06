//
//  Environment+SpeechSynthesizer.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import SwiftUI
import Foundation

private struct MissingSpeechSynthesizer: SpeechSynthesizing {
    func synthesizeSpeech(
        from text: String,
        voice: String,
        speed: Double?
    ) async throws -> Data {
        assertionFailure("speechSynthesizer environment value was not injected.")
        return Data()
    }

    func synthesizeSpeechStream(
        from text: String,
        voice: String,
        speed: Double?
    ) -> AsyncThrowingStream<Data, Error> {
        assertionFailure("speechSynthesizer environment value was not injected.")
        return AsyncThrowingStream { continuation in
            continuation.finish()
        }
    }
}

private struct SpeechSynthesizerKey: EnvironmentKey {
    static let defaultValue: any SpeechSynthesizing = MissingSpeechSynthesizer()
}

extension EnvironmentValues {
    var speechSynthesizer: any SpeechSynthesizing {
        get { self[SpeechSynthesizerKey.self] }
        set { self[SpeechSynthesizerKey.self] = newValue }
    }
}
