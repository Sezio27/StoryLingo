//
//  ReplyCardItem.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 09/03/2026.
//

import Foundation

enum ReplyCardKind: String, Codable {
    case category
    case custom
}

struct ReplyCardItem: Identifiable, Equatable {
    let id: UUID
    let kind: ReplyCardKind
    let category: CardCategory?
    let text: String
    let translationText: String?
    let sourceText: String?

    init(
        id: UUID = UUID(),
        kind: ReplyCardKind,
        category: CardCategory? = nil,
        text: String,
        translationText: String? = nil,
        sourceText: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.category = category
        self.text = text
        self.translationText = translationText
        self.sourceText = sourceText
    }
}
