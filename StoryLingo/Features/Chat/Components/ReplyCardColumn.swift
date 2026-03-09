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

    var body: some View {
        VStack(spacing: 12) {
            ForEach(cards) { card in
                Button {
                    onTap(card)
                } label: {
                    ReplyCardView(
                        card: card,
                        isSelected: selectedCardID == card.id
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
