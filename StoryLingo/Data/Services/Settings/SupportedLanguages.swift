//
//  SupportedLangauges.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

enum SupportedLanguages {
    static let all: [LanguageOption] = LanguageCatalog.appSupported.map {
        .init(code: $0.code, name: $0.displayName, flag: $0.flagEmoji)
    }
}
