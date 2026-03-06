//
//  LanguageDTO.swift
//  StoryLingo
//
//  Created by Codex on 05/03/2026.
//

import Foundation

struct LanguageDTO: Hashable {
    let code: String
    let displayName: String
    let flagEmoji: String
}

enum LanguageCatalog {
    static let all: [LanguageDTO] = [
        .init(code: "en", displayName: "English", flagEmoji: "🇬🇧"),
        .init(code: "da", displayName: "Danish", flagEmoji: "🇩🇰"),
        .init(code: "de", displayName: "German", flagEmoji: "🇩🇪"),
        .init(code: "es", displayName: "Spanish", flagEmoji: "🇪🇸"),
        .init(code: "fr", displayName: "French", flagEmoji: "🇫🇷"),
        .init(code: "it", displayName: "Italian", flagEmoji: "🇮🇹"),
        .init(code: "ja", displayName: "Japanese", flagEmoji: "🇯🇵"),
        .init(code: "ko", displayName: "Korean", flagEmoji: "🇰🇷"),
        .init(code: "ro", displayName: "Romanian", flagEmoji: "🇷🇴"),
        .init(code: "th", displayName: "Thai", flagEmoji: "🇹🇭")
    ]

}
