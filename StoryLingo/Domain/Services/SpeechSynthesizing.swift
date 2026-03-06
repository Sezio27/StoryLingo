//
//  SpeechSynthesizing.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation

public protocol SpeechSynthesizing: Sendable {
    func synthesizeSpeech(
        from text: String,
        voice: String,
        speed: Double?
    ) async throws -> Data

    func synthesizeSpeechStream(
        from text: String,
        voice: String,
        speed: Double?
    ) -> AsyncThrowingStream<Data, Error>
}
