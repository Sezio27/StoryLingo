//
//  Message+Extensions.swift
//  StoryLingo
//

import Foundation

extension Message {
    var translatedTextSafe: String? {
        let value = translatedText?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (value?.isEmpty == false) ? value : nil
    }

    var hasTranslation: Bool {
        translatedTextSafe != nil
    }
}
