//
//  OpenAIClient.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import Foundation

public final class OpenAIClient: LLMClient {
    public struct Configuration: Sendable {
        public var apiKey: String
        public var baseURL: URL
        public var defaultModel: String

        public init(
            apiKey: String,
            baseURL: URL = URL(string: "https://api.openai.com/v1/responses")!,
            defaultModel: String = "gpt-5.2"
        ) {
            self.apiKey = apiKey
            self.baseURL = baseURL
            self.defaultModel = defaultModel
        }
    }

    public enum OpenAIClientError: LocalizedError {
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case emptyOutputText

        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from OpenAI."
            case .httpError(let status, let message):
                return "OpenAI HTTP \(status): \(message)"
            case .emptyOutputText:
                return "OpenAI response had no output_text."
            }
        }
    }

    private let config: Configuration
    private let session: URLSession

    public init(config: Configuration, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    // MARK: - LLMClient

    public func generateText(
        messages: [LLMMessage],
        model: String,
        temperature: Double? = nil,
        maxOutputTokens: Int? = nil
    ) async throws -> String {

        let requestBody = ResponsesCreateRequest(
            model: model.isEmpty ? config.defaultModel : model,
            input: messages.map { .init(role: $0.role.rawValue, content: $0.content) },
            temperature: temperature,
            maxOutputTokens: maxOutputTokens
        )

        var req = URLRequest(url: config.baseURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("Bearer \(config.apiKey)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        req.httpBody = try encoder.encode(requestBody)

        let (data, response) = try await session.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw OpenAIClientError.invalidResponse
        }

        // Non-2xx: attempt to parse OpenAI error payload
        guard (200...299).contains(http.statusCode) else {
            let message =
                (try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data).error.message)
                ?? String(data: data, encoding: .utf8)
                ?? "Unknown error"
            throw OpenAIClientError.httpError(statusCode: http.statusCode, message: message)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let decoded = try decoder.decode(ResponsesCreateResponse.self, from: data)

        // Preferred: direct output_text
        if let text = decoded.outputText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !text.isEmpty {
            return text
        }

        // Fallback: reconstruct from output[].content[] where type == "output_text"
        let reconstructed = decoded.output?
            .compactMap { $0.content }
            .flatMap { $0 }
            .filter { $0.type == "output_text" }
            .compactMap { $0.text }
            .joined()

        if let reconstructed, !reconstructed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return reconstructed
        }

        throw OpenAIClientError.emptyOutputText
    }

    // MARK: - DTOs

    private struct ResponsesCreateRequest: Encodable {
        let model: String
        let input: [InputMessage]
        let temperature: Double?
        let maxOutputTokens: Int?
    }

    /// Responses API input message shape: { role, content }
    private struct InputMessage: Encodable {
        let role: String
        let content: String
    }

    private struct ResponsesCreateResponse: Decodable {
        let outputText: String?
        let output: [OutputItem]?
    }

    private struct OutputItem: Decodable {
        let type: String
        let role: String?
        let content: [OutputContentPart]?
    }

    private struct OutputContentPart: Decodable {
        let type: String
        let text: String?
    }

    private struct OpenAIErrorEnvelope: Decodable {
        let error: OpenAIError
    }

    private struct OpenAIError: Decodable {
        let message: String
        let type: String?
        let code: String?
    }
}
