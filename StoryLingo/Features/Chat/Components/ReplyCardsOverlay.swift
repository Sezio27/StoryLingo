import SwiftUI

struct ReplyCardsOverlay: View {
    let cards: [ReplyCardItem]
    let selectedCardID: UUID?
    let onTap: (ReplyCardItem) -> Void
    let onSubmitCustom: (String) -> Void
    let onClose: () -> Void

    @State private var customText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Reply Cards")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                Spacer()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color(.tertiarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)
            }

            ReplyCardColumn(
                cards: cards,
                selectedCardID: selectedCardID,
                onTap: onTap
            )

            VStack(alignment: .leading, spacing: 8) {
                Text("Write your own")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    TextField("Type what you want to say", text: $customText)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )

                    Button {
                        let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        onSubmitCustom(trimmed)
                    } label: {
                        Text("Submit")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.accentColor)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        )
    }
}
