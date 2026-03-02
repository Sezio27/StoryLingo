//
//  Language+Convenience.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import Foundation

extension Language {
    var codeSafe: String { code ?? "" }
    var displayNameSafe: String { displayName ?? "" }
    var flagEmojiSafe: String { flagEmoji ?? "" }
}

