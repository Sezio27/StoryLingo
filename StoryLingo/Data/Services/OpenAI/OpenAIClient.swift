//
//  OpenAIClient.swift
//  StoryLingo
//
//  Created by Codex on 2026-03-06.
//

import Foundation

enum OpenAIClientError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case emptyChoices
}

protocol OpenAIClient {
    func createChatCompletion(
        model: String,
        messages: [OpenAIChatMessageDTO],
        maxTokens: Int?,
        temperature: Double?
    ) async throws -> OpenAIChatMessageDTO
}

struct DefaultOpenAIClient: OpenAIClient {
    private let apiKey: String
    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(
        apiKey: String,
        baseURL: URL = URL(string: "https://api.openai.com/v1")!,
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func createChatCompletion(
        model: String,
        messages: [OpenAIChatMessageDTO],
        maxTokens: Int? = nil,
        temperature: Double? = nil
    ) async throws -> OpenAIChatMessageDTO {
        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let payload = OpenAIChatCompletionRequestDTO(
            model: model,
            messages: messages,
            maxTokens: maxTokens,
            temperature: temperature
        )

        request.httpBody = try encoder.encode(payload)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIClientError.httpError(statusCode: httpResponse.statusCode)
        }

        let completion = try decoder.decode(OpenAIChatCompletionResponseDTO.self, from: data)
        guard let firstChoice = completion.choices.first else {
            throw OpenAIClientError.emptyChoices
        }

        return firstChoice.message
    }
}
