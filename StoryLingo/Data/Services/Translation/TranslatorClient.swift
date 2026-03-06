import Foundation

struct TranslationResult: Equatable {
    let translatedText: String
    let detectedSourceLanguageCode: String?
    let targetLanguageCode: String
}

protocol TranslatorClient {
    func translateForLearning(
        text: String,
        nativeLanguageCode: String,
        nativeLanguageName: String,
        targetLanguageCode: String,
        targetLanguageName: String
    ) async throws -> TranslationResult
}
