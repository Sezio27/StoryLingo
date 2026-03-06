import Foundation

public final class OpenAITTSService: SpeechSynthesizing, @unchecked Sendable {
    public enum OpenAITTSError: LocalizedError {
        case invalidResponse
        case httpError(statusCode: Int, message: String)
        case emptyAudioData

        public var errorDescription: String? {
            switch self {
            case .invalidResponse:
                return "Invalid response from OpenAI speech endpoint."
            case .httpError(let statusCode, let message):
                return "OpenAI HTTP \(statusCode): \(message)"
            case .emptyAudioData:
                return "OpenAI returned empty audio data."
            }
        }
    }

    private struct RequestBody: Encodable {
        let model: String
        let input: String
        let voice: String
        let responseFormat: String
        let speed: Double?

        enum CodingKeys: String, CodingKey {
            case model
            case input
            case voice
            case responseFormat = "response_format"
            case speed
        }
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
        model: String = "gpt-4o-mini-tts",
        baseURL: URL = URL(string: "https://api.openai.com/v1/audio/speech")!,
        session: URLSession = .shared
    ) {
        self.apiKey = apiKey
        self.model = model
        self.baseURL = baseURL
        self.session = session
    }

    public func synthesizeSpeech(
        from text: String,
        voice: String,
        speed: Double? = nil
    ) async throws -> Data {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return Data() }

        var request = baseRequest()
        let body = RequestBody(
            model: model,
            input: trimmed,
            voice: voice,
            responseFormat: "wav",
            speed: speed
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        try validate(response: response, data: data)

        guard !data.isEmpty else {
            throw OpenAITTSError.emptyAudioData
        }

        return data
    }

    public func synthesizeSpeechStream(
        from text: String,
        voice: String,
        speed: Double? = nil
    ) -> AsyncThrowingStream<Data, Error> {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return AsyncThrowingStream { continuation in
            guard !trimmed.isEmpty else {
                continuation.finish()
                return
            }

            let task = Task {
                do {
                    var request = baseRequest()
                    let body = RequestBody(
                        model: model,
                        input: trimmed,
                        voice: voice,
                        responseFormat: "pcm",
                        speed: speed
                    )
                    request.httpBody = try JSONEncoder().encode(body)

                    let (bytes, response) = try await session.bytes(for: request)

                    try validate(response: response, data: nil)

                    for try await chunk in bytes.chunked(into: 4096) {
                        continuation.yield(Data(chunk))
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func baseRequest() -> URLRequest {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validate(response: URLResponse, data: Data?) throws {
        guard let http = response as? HTTPURLResponse else {
            throw OpenAITTSError.invalidResponse
        }

        guard (200 ... 299).contains(http.statusCode) else {
            let message = data.flatMap {
                (try? JSONDecoder().decode(ErrorEnvelope.self, from: $0).error.message)
                    ?? String(data: $0, encoding: .utf8)
            } ?? "Unknown error"

            throw OpenAITTSError.httpError(statusCode: http.statusCode, message: message)
        }
    }
}

private extension URLSession.AsyncBytes {
    func chunked(into size: Int) -> AsyncThrowingStream<[UInt8], Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    var buffer: [UInt8] = []
                    buffer.reserveCapacity(size)

                    for try await byte in self {
                        buffer.append(byte)
                        if buffer.count >= size {
                            continuation.yield(buffer)
                            buffer.removeAll(keepingCapacity: true)
                        }
                    }

                    if !buffer.isEmpty {
                        continuation.yield(buffer)
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
