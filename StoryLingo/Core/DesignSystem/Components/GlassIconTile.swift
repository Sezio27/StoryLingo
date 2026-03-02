//
//  GlassIconTile.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct GlassIconTile: View {
    // Content
    var emoji: String? = "📜"
    var systemImage: String? = nil

    // Sizing / style
    var size: CGFloat = 120
    var cornerRadius: CGFloat = 28
    var material: Material = .ultraThinMaterial

    // Color tuning
    var gradientOpacities: (Double, Double, Double) = (0.55, 0.35, 0.15)
    var highlightOpacities: (Double, Double) = (0.55, 0.08)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(material)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(gradientOpacities.0),
                                    Color.cyan.opacity(gradientOpacities.1),
                                    Color.white.opacity(gradientOpacities.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(highlightOpacities.0),
                                    Color.white.opacity(highlightOpacities.1),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.12), radius: 18, y: 12)

            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
            } else if let emoji {
                Text(emoji)
                    .font(.system(size: size * 0.38))
                    .shadow(color: .black.opacity(0.10), radius: 8, y: 4)
            }
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 16) {
        GlassIconTile(emoji: "📜")
        GlassIconTile(systemImage: "sparkles")
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
