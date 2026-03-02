//
//  FeatureRow.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct GoalProgressCard: View {
    let icon: String
    let iconTint: Color
    let iconBackground: Color

    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let value: LocalizedStringKey

    let progress: Double
    let footer: LocalizedStringKey

    var progressTint: Color? = nil

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(iconBackground)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconTint)
            }
            .frame(width: 52, height: 52)

            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                    Spacer()
                    Text(value)
                        .foregroundStyle(.secondary)
                }

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                ProgressView(value: max(0, min(1, progress)))
                    .tint(progressTint ?? iconTint)

                Text(footer)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
    }
}
