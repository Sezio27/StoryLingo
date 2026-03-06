//
//  LLMTranslatorClient.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

struct LLMTranslatorClient: TranslatorClient {
    private let llm: LLMClient
    private let model: String

    init(
        llm: LLMClient,
        model: String = "gpt-5.2"
    ) {
        self.llm = llm
        self.model = model
    }

    func translateForLearning(
        text: String,
        nativeLanguageCode: String,
        nativeLanguageName: String,
        targetLanguageCode: String,
        targetLanguageName: String
    ) async throws -> TranslationResult {
        let systemPrompt = """
    You are a translation engine for a language-learning app.

    The user may write in either:
    1. their native language: \(nativeLanguageName) (\(nativeLanguageCode))
    2. their target language: \(targetLanguageName) (\(targetLanguageCode))

    Your job:
    - Detect whether the input is primarily in the native language or the target language.
    - Translate it into the opposite language.
    - Keep the user's intent, tone, and unusual phrasing when possible.
    - Do not over-correct awkward wording or mistakes.
    - If the user makes mistakes, keep the translation close to what they actually said rather than silently rewriting it into perfect language.
    - If the wording is strange, funny, or imperfect, preserve that feeling in the translation when reasonable.
    - Do not explain anything.
    - Do not add extra text.
    - Return valid JSON only.

    JSON format:
    {
      "translatedText": "string",
      "detectedSourceLanguageCode": "string",
      "targetLanguageCode": "string"
    }

    Rules:
    - If the input is in \(nativeLanguageCode), translate to \(targetLanguageCode).
    - If the input is in \(targetLanguageCode), translate to \(nativeLanguageCode).
    - If mixed, choose the dominant language.
    - Output only JSON.
    """

        let response = try await llm.generateText(
            messages: [
                .init(role: .system, content: systemPrompt),
                .init(role: .user, content: text)
            ],
            model: model,
            temperature: 0,
            maxOutputTokens: 200
        )

        return try decodeTranslationResult(from: response)
    }

    private func decodeTranslationResult(from response: String) throws -> TranslationResult {
        let data = Data(response.utf8)
        let dto = try JSONDecoder().decode(TranslationDTO.self, from: data)

        return TranslationResult(
            translatedText: dto.translatedText,
            detectedSourceLanguageCode: dto.detectedSourceLanguageCode,
            targetLanguageCode: dto.targetLanguageCode
        )
    }
}


