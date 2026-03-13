import SwiftUI

struct ReplyCardsOverlay: View {
    let cards: [ReplyCardItem]
    let selectedCardID: UUID?
    let onTap: (ReplyCardItem) -> Void
    let onSpeak: (ReplyCardItem) -> Void
    let onSubmitCustom: (String) async -> BubbleTranslation?
    let onSpeakCustomTranslation: (BubbleTranslation) async -> Void
    let onClose: () -> Void

    @State private var customText: String = ""
    @State private var customTranslation: BubbleTranslation?
    @State private var isCustomEditorVisible = false
    @State private var isSubmittingCustom = false
    @State private var isPlayingCustomTranslation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if isCustomEditorVisible {
                customComposer
            } else {
                cardsView
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color(.tertiarySystemGroupedBackground))
                    )
            }
            .buttonStyle(.plain)
            .offset(x: 12, y: -12)
            .zIndex(1)
        }.padding(.top, 3)
    }

    private var cardsView: some View {
        VStack(alignment: .leading, spacing: 18) {
            ReplyCardColumn(
                cards: cards,
                selectedCardID: selectedCardID,
                onTap: onTap,
                onSpeak: onSpeak
            )

            HStack {
                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCustomEditorVisible = true
                        customTranslation = nil
                    }
                } label: {
                    Text("Write your own")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(
                            Capsule(style: .continuous)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.top, 2)
        }
    }

    private var customComposer: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Translated text")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))

                if (customTranslation?.text ?? "").isEmpty {
                    Text("Translation will appear here")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }

                TextEditor(text: .constant(customTranslation?.text ?? ""))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .disabled(true)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(minHeight: 110)

            if let customTranslation {
                Button {
                    Task {
                        isPlayingCustomTranslation = true
                        await onSpeakCustomTranslation(customTranslation)
                        isPlayingCustomTranslation = false
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: isPlayingCustomTranslation ? "speaker.wave.3.fill" : "play.fill")
                        Text(isPlayingCustomTranslation ? "Playing…" : "Play translation")
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                     .foregroundStyle(.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(isPlayingCustomTranslation)
            }

            Text("Your text")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))

                if customText.isEmpty {
                    Text("Type what you want to say")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $customText)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
            .frame(minHeight: 120)

            HStack(spacing: 12) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isCustomEditorVisible = false
                        customText = ""
                        customTranslation = nil
                    }
                } label: {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color(.secondarySystemGroupedBackground))
                        )
                }
                .buttonStyle(.plain)

                Button {
                    let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }

                    Task {
                        isSubmittingCustom = true
                        customTranslation = await onSubmitCustom(trimmed)
                        isSubmittingCustom = false
                    }
                } label: {
                    Text(isSubmittingCustom ? "Translating…" : "Submit")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(Color.accentColor)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isSubmittingCustom)
            }

            Spacer(minLength: 0)
        }
    }
}
