//
//  NewStoryButton.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI

struct NewStoryButton: View {
    let title: String
    let systemImage: String
    var trailingSparkle: Bool = true
    var action: () -> Void

    // Tuning knobs
    var cornerRadius: CGFloat = 18
    var glowOpacity: Double = 0.1       // ⬅️ adjust this if too bright
    var glowEndRadius: CGFloat = 110      // ⬅️ adjust size of glow
    var sparkleOpacity: Double = 0.7

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))

                Text(title)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(background)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: Color.blue.opacity(0.30), radius: 18, y: 10)
            .shadow(color: Color.cyan.opacity(0.18), radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }

    private var background: some View {
        ZStack {
            // Base gradient
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.cyan,
                            Color.indigo
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Soft “magic” glow (this is what made it too bright)
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(glowOpacity),
                            Color.clear
                        ],
                        center: .topLeading,
                        startRadius: 12,
                        endRadius: glowEndRadius
                    )
                )
                .blendMode(.screen)

            // Sparkle overlay (subtle)
            if trailingSparkle {
                HStack {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white.opacity(sparkleOpacity))
                        .padding(.trailing, 18)
                }
            }
        }
    }
}

#Preview {
    NewStoryButton(title: "Create New Story", systemImage: "wand.and.stars") { }
        .padding()
}
