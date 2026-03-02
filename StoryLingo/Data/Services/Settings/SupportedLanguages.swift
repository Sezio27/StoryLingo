//
//  SupportedLangauges.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

enum SupportedLanguages {
    static let all: [LanguageOption] = [
        .init(code: "fr", name: "French", flag: "🇫🇷"),
        .init(code: "es", name: "Spanish", flag: "🇪🇸"),
        .init(code: "de", name: "German", flag: "🇩🇪"),
        .init(code: "it", name: "Italian", flag: "🇮🇹"),
        .init(code: "da", name: "Danish", flag: "🇩🇰")
    ]
}
