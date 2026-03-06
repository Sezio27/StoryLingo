//
//  OpenAIDTOs.swift
//  StoryLingo
//
//  Created by Codex on 2026-03-06.
//

import Foundation

struct OpenAIChatCompletionRequestDTO: Encodable {
    let model: String
    let messages: [OpenAIChatMessageDTO]
    let maxTokens: Int?
    let temperature: Double?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case maxTokens = "max_tokens"
        case temperature
    }
}

struct OpenAIChatMessageDTO: Codable {
    let role: String
    let content: String
}

struct OpenAIChatCompletionResponseDTO: Decodable {
    let id: String
    let choices: [OpenAIChoiceDTO]
}

struct OpenAIChoiceDTO: Decodable {
    let index: Int
    let message: OpenAIChatMessageDTO
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}
