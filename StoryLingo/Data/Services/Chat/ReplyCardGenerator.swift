import Foundation

protocol ReplyCardGenerating {
    func generateReplyCards(
        categories: [CardCategory],
        recentHistory: [LLMMessage],
        context: ReplyCardPromptContext
    ) async throws -> [ReplyCardItem]
}

struct LLMReplyCardGenerator: ReplyCardGenerating {
    private let llm: LLMClient
    private let model: String
    private let promptBuilder: ReplyCardPromptBuilder

    init(
        llm: LLMClient,
        model: String = "gpt-5.2",
        promptBuilder: ReplyCardPromptBuilder = ReplyCardPromptBuilder()
    ) {
        self.llm = llm
        self.model = model
        self.promptBuilder = promptBuilder
    }

    func generateReplyCards(
        categories: [CardCategory],
        recentHistory: [LLMMessage],
        context: ReplyCardPromptContext
    ) async throws -> [ReplyCardItem] {
        let developerPrompt = promptBuilder.makeDeveloperPrompt(
            categories: categories,
            recentHistory: recentHistory,
            context: context,
            difficulty: context.difficulty
        )

        let response = try await llm.generateText(
            messages: [.init(role: .developer, content: developerPrompt)],
            model: model,
            temperature: 0.8,
            maxOutputTokens: 300
        )

        let decoded = try decodeCards(response)
        let byCategory = Dictionary(uniqueKeysWithValues: decoded.cards.map { ($0.category, $0) })

        return categories.compactMap { category in
            guard let dto = byCategory[category] else { return nil }

            return ReplyCardItem(
                kind: .category,
                category: category,
                text: dto.replyText,
                translationText: dto.translatedText,
                sourceText: dto.replyText
            )
        }
    }

    private func decodeCards(_ response: String) throws -> ReplyCardsDTO {
        let data = Data(response.utf8)
        return try JSONDecoder().decode(ReplyCardsDTO.self, from: data)
    }
}
