//
//  AudioTranscribing.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

public protocol AudioTranscribing: Sendable {
    func transcribeAudio(
        fileURL: URL,
        language: String?
    ) async throws -> String
}
