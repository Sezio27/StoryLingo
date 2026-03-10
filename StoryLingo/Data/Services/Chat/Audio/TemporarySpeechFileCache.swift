//
//  TemporarySpeechFileCache.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 10/03/2026.
//

import Foundation
import CryptoKit

struct TemporarySpeechFileCache {
    struct Key: Hashable {
        let text: String
        let languageCode: String
        let voice: String
        let speed: Double
        let instructions: String

        var fileName: String {
            let raw = "\(languageCode)|\(voice)|\(speed)|\(instructions)|\(text)"
            let digest = SHA256.hash(data: Data(raw.utf8))
            return digest.map { String(format: "%02x", $0) }.joined()
        }
    }

    private let directory: URL

    init() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("reply-card-audio", isDirectory: true)

        try? FileManager.default.createDirectory(
            at: url,
            withIntermediateDirectories: true,
            attributes: nil
        )

        self.directory = url
    }

    func cachedURL(for key: Key) -> URL? {
        let url = directory.appendingPathComponent(key.fileName).appendingPathExtension("wav")
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    @discardableResult
    func store(_ data: Data, for key: Key) throws -> URL {
        let url = directory.appendingPathComponent(key.fileName).appendingPathExtension("wav")
        try data.write(to: url, options: .atomic)
        return url
    }
}
