//
//  StoriesCardRow.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 14/02/2026.
//

import SwiftUI

struct StoryCardRow: View {
    let title: String
    let relativeTime: String
    let messageCount: Int

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)

                HStack(spacing: 18) {
                    Label(relativeTime, systemImage: "clock")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)

                    Label("\(messageCount)", systemImage: "bubble.left")
                        .labelStyle(.titleAndIcon)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }
}

#Preview {
    StoryCardRow(title: "A Trip to the Market", relativeTime: "2 hours ago", messageCount: 24)
        .padding()
        .background(Color(.systemGroupedBackground))
}
