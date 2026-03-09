//
//  String+WordNormalization.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 08/03/2026.
//

import Foundation
import NaturalLanguage

extension String {
    func normalizedWords() -> Set<String> {
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = self

        var words = Set<String>()

        tokenizer.enumerateTokens(in: startIndex..<endIndex) { range, _ in
            let token = String(self[range])
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .lowercased()
                .trimmingCharacters(in: .punctuationCharacters.union(.symbols).union(.whitespacesAndNewlines))

            guard token.count >= 2 else { return true }
            words.insert(token)
            return true
        }

        return words
    }
}
