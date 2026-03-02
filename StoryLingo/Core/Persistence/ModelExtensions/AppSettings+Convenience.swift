//
//  AppSettings+Convenience.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

extension AppSettings {
    var difficulty: DifficultyLevel {
        get { DifficultyLevel(rawValue: level) ?? .intermediate }
        set { level = newValue.rawValue }
    }

    var selectedLanguageSafe: Language? {
        selectedLanguage
    }
}
