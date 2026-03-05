//
//  LLMClient+Environment.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import SwiftUI

private struct LLMClientKey: EnvironmentKey {
    static let defaultValue: any LLMClient = MockLLMClient()
}

extension EnvironmentValues {
    var llmClient: any LLMClient {
        get { self[LLMClientKey.self] }
        set { self[LLMClientKey.self] = newValue }
    }
}

/// For previews / fallback (so the app doesn't crash if no key)
private struct MockLLMClient: LLMClient {
    func generateText(
        messages: [LLMMessage],
        model: String,
        temperature: Double?,
        maxOutputTokens: Int?
    ) async throws -> String {
        "Mock reply 🤖"
    }
}
