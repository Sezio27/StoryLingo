//
//  ReplyCardColumn.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 09/03/2026.
//

import SwiftUI

struct ReplyCardColumn: View {
    let cards: [ReplyCardItem]
    let selectedCardID: UUID?
    let onTap: (ReplyCardItem) -> Void
    let onSpeak: (ReplyCardItem) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(cards) { card in
                ReplyCardView(
                    card: card,
                    isSelected: selectedCardID == card.id,
                    onTap: { onTap(card) },
                    onSpeak: { onSpeak(card) }
                )
                .frame(maxWidth: .infinity)
            }
        }
    }
}
