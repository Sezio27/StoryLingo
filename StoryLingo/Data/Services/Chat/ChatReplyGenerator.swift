//
//  ChatReplyGenerator.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

struct ChatReplyResult: Equatable {
    let replyText: String
    let translatedText: String
}

protocol ChatReplyGenerating {
    func generateReply(
        history: [LLMMessage],
        context: ChatPromptContext
    ) async throws -> ChatReplyResult
}

struct LLMChatReplyGenerator: ChatReplyGenerating {
    private let llm: LLMClient
    private let model: String
    private let promptBuilder: ChatPromptBuilder

    init(
        llm: LLMClient,
        model: String = "gpt-5.2",
        promptBuilder: ChatPromptBuilder = ChatPromptBuilder()
    ) {
        self.llm = llm
        self.model = model
        self.promptBuilder = promptBuilder
    }

    func generateReply(
        history: [LLMMessage],
        context: ChatPromptContext
    ) async throws -> ChatReplyResult {
        let developerPrompt = promptBuilder.makeDeveloperPrompt(context: context)

        let response = try await llm.generateText(
            messages: [.init(role: .developer, content: developerPrompt)] + history,
            model: model,
            temperature: 0.7,
            maxOutputTokens: 300
        )

        return try decodeReply(from: response)
    }

    private func decodeReply(from response: String) throws -> ChatReplyResult {
        let data = Data(response.utf8)
        let dto = try JSONDecoder().decode(ChatReplyDTO.self, from: data)

        return ChatReplyResult(
            replyText: dto.replyText,
            translatedText: dto.translatedText
        )
    }
}

private struct ChatReplyDTO: Decodable {
    let replyText: String
    let translatedText: String
}
