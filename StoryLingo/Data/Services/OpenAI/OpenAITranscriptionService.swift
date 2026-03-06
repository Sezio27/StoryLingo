//
//  OpenAITranscriptionService.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

public final class OpenAITranscriptionService: AudioTranscribing, @unchecked Sendable {
    public enum OpenAITranscriptionError: LocalizedError {
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case missingTranscript

        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from OpenAI transcription endpoint."
            case .httpError(let statusCode, let message):
                return "OpenAI HTTP \(statusCode): \(message)"
            case .missingTranscript:
                return "OpenAI transcription response did not contain text."
            }
        }
    }

    private struct TranscriptionResponse: Decodable {
        let text: String?
    }

    private struct ErrorEnvelope: Decodable {
        struct APIError: Decodable {
            let message: String
        }
        let error: APIError
    }

    private let apiKey: String
    private let session: URLSession
    private let baseURL: URL
    private let model: String

    public init(
        apiKey: String,
        model: String = "gpt-4o-mini-transcribe",
        baseURL: URL = URL(string: "https://api.openai.com/v1/audio/transcriptions")!,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.session = session
    }

    public func transcribeAudio(
        fileURL: URL,
        language: String? = nil
    ) async throws -> String {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let audioData = try Data(contentsOf: fileURL)
        let filename = fileURL.lastPathComponent

        var body = Data()

        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        appendField("model", model)
        appendField("response_format", "json")

        if let language, !language.isEmpty {
            appendField("language", language)
        }

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw OpenAITranscriptionError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = (try? JSONDecoder().decode(ErrorEnvelope.self, from: data).error.message)
                ?? String(data: data, encoding: .utf8)
                ?? "Unknown error"
            throw OpenAITranscriptionError.httpError(statusCode: http.statusCode, message: message)
        }

        let decoded = try JSONDecoder().decode(TranscriptionResponse.self, from: data)
        guard let text = decoded.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else {
            throw OpenAITranscriptionError.missingTranscript
        }

        return text
    }
}
