import SwiftUI

struct ReplyCardView: View {
    let card: ReplyCardItem
    let isSelected: Bool
    let onTap: () -> Void
    let onSpeak: () -> Void

    private var tint: Color {
        card.category?.tint ?? .accentColor
    }

    private var title: String {
        card.category?.title ?? "Custom"
    }

    private var systemImage: String {
        card.category?.systemImage ?? "square.and.pencil"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(tint)

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(card.text)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let translationText = card.translationText {
                    Text(translationText)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(14)
        .padding(.trailing, 56) // leaves space for the speaker button
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            isSelected ? tint : Color(.separator).opacity(0.25),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
        )
        .overlay(alignment: .trailing) {
            Button(action: onSpeak) {
                Image(systemName: "speaker.wave.2.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
            }
            .buttonStyle(.plain)
            .padding(.trailing, 14)
        }
        .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        .scaleEffect(isSelected ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .onTapGesture(perform: onTap)
    }
}
