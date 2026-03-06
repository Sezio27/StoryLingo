//
//  Appcontainer.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import Foundation

final class AppContainer {
    let llmClient: any LLMClient
    let speechSynthesizer: any SpeechSynthesizing
    let speechRecognizerService: SpeechRecognizerServiceProtocol

    init() {
        let key = (Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String) ?? ""

        llmClient = OpenAIClient(config: .init(apiKey: key))
        speechSynthesizer = OpenAITTSService(apiKey: key)

        let transcriber = OpenAITranscriptionService(
            apiKey: key,
            model: "gpt-4o-mini-transcribe"
        )
        speechRecognizerService = SpeechRecognizerService(transcriber: transcriber)
    }
}
