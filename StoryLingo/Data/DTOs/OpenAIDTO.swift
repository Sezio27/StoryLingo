//
//  OpenAIDTO.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//


import Foundation


struct ResponsesCreateRequest: Encodable {
    let model: String
    let input: [InputMessage]
    let temperature: Double?
    let maxOutputTokens: Int?
}

/// Responses API input message shape: { role, content }
struct InputMessage: Encodable {
    let role: String
    let content: String
}

struct ResponsesCreateResponse: Decodable {
    let outputText: String?
    let output: [OutputItem]?
}

struct OutputItem: Decodable {
    let type: String
    let role: String?
    let content: [OutputContentPart]?
}

struct OutputContentPart: Decodable {
    let type: String
    let text: String?
}

struct OpenAIErrorEnvelope: Decodable {
    let error: OpenAIError
}

struct OpenAIError: Decodable {
    let message: String
    let type: String?
    let code: String?
}

