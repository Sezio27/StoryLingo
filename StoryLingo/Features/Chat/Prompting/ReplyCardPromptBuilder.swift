import Foundation

struct ReplyCardPromptContext {
    let nativeLanguageCode: String
    let nativeLanguageName: String
    let targetLanguageCode: String
    let targetLanguageName: String
    let difficulty: DifficultyLevel
}

struct ReplyCardPromptBuilder {
    func makeDeveloperPrompt(
        categories: [CardCategory],
        recentHistory: [LLMMessage],
        context: ReplyCardPromptContext,
        difficulty: DifficultyLevel
    ) -> String {
        let categoryList = categories.map(\.rawValue).joined(separator: ", ")
        let historyLines = recentHistory.enumerated().map { index, message in
            "\(index + 1). [\(message.role.rawValue)] \(message.content)"
        }.joined(separator: "\n")

        let historyBlock = historyLines.isEmpty ? "(no previous messages)" : historyLines

        return """
        You generate short reply cards for a language-learning roleplay chat.

        Learner profile:
        - Native language: \(context.nativeLanguageName) (\(context.nativeLanguageCode))
        - Target language: \(context.targetLanguageName) (\(context.targetLanguageCode))
        - Difficulty: \(difficulty.rawValue)

        Use these exact categories (one reply per category): \(categoryList)

        Recent chat context (last up to 4 messages):
        \(historyBlock)

        Requirements:
        - Create one short, natural reply for each category.
        - replyText must be in \(context.targetLanguageCode).
        - translatedText must be in \(context.nativeLanguageCode).
        - Keep each replyText concise (about 4-12 words).
        - Keep the tone clearly matching the category.
        - Reflect the recent context when possible.
        - Return all requested categories exactly once.

        \(difficultyGuidance(for: difficulty))

        Output JSON only with this exact shape:
        {
          "cards": [
            {
              "category": "one of the requested category raw values",
              "replyText": "short reply in \(context.targetLanguageCode)",
              "translatedText": "translation in \(context.nativeLanguageCode)"
            }
          ]
        }
        """
    }


    private func difficultyGuidance(for difficulty: DifficultyLevel) -> String {
        switch difficulty {
        case .beginner:
            return """
            Difficulty adaptation:
            - Use very simple, common vocabulary and short sentence patterns.
            - Prefer present tense and literal, direct phrasing.
            - Avoid idioms, slang, figurative language, and complex clause chaining.
            - Keep learner replies easy to pronounce and imitate.
            """
        case .intermediate:
            return """
            Difficulty adaptation:
            - Use everyday vocabulary with moderate variety.
            - Allow occasional idiomatic phrasing if context makes meaning clear.
            - Keep grammar natural but avoid dense or highly literary constructions.
            - Balance clarity with natural conversational flow.
            """
        case .advanced:
            return """
            Difficulty adaptation:
            - Use richer vocabulary and more nuanced tone while staying concise.
            - You may include idioms and stylistic phrasing that fit the scene.
            - Allow more complex sentence structure when natural for the category.
            - Keep outputs practical for roleplay, not academic.
            """
        }
    }

}
