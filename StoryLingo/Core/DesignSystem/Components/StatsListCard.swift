//
//  StatListCard.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 27/02/2026.
//

import SwiftUI

struct StatsListCard: View {
    struct Item: Identifiable {
        let id = UUID()
        let icon: String
        let iconTint: Color
        let iconBackground: Color
        let title: LocalizedStringKey
        let value: LocalizedStringKey
    }

    let items: [Item]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                StatsListRow(item: item)
                    .padding(.vertical, 18)

                if index < items.count - 1 {
                    Divider()
                        .padding(.leading, 72) // lines up after the icon
                }
            }
        }
        .padding(.horizontal, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }
}


