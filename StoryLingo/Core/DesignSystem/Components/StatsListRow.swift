//
//  StatListRow.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 27/02/2026.
//

import SwiftUI

struct StatsListRow: View {
    let item: StatsListCard.Item

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(item.iconBackground)

                Image(systemName: item.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(item.iconTint)
            }
            .frame(width: 42, height: 42)

            Text(item.title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            Text(item.value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
        }
    }
}
