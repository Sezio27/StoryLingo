//
//  LLMClient.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import Foundation

public enum LLMRole: String, Codable, Sendable {
    case system
    case developer
    case user
    case assistant
}

public struct LLMMessage: Codable, Equatable, Sendable {
    public let role: LLMRole
    public let content: String

    public init(role: LLMRole, content: String) {
        self.role = role
        self.content = content
    }
}

public protocol LLMClient: Sendable {
    /// Generates a single assistant text response given the conversation so far.
    func generateText(
        messages: [LLMMessage],
        model: String,
        temperature: Double?,
        maxOutputTokens: Int?
    ) async throws -> String
}
