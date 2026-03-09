import SwiftUI
import CoreData

struct CreateStoryView: View {
    @ObservedObject var settings: AppSettings
    let onStoryCreated: (Story) -> Void

    @Environment(\.managedObjectContext) private var ctx
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var genre: String = ""
    @State private var theme: String = ""
    @State private var place: String = ""
    @State private var errorMessage: String?

    var body: some View {
        PageScaffold(
            title: "New Story",
            subtitle: "Optional details to guide the story",
            scrolls: true,
            showsBackButton: true
        ) {
            VStack(spacing: 16) {
                OptionalField(
                    label: "Story title (optional)",
                    placeholder: "e.g. The Lost Key",
                    text: $title
                )

                OptionalField(
                    label: "Genre (optional)",
                    placeholder: "e.g. Mystery, Fantasy, Sci-Fi",
                    text: $genre
                )

                OptionalField(
                    label: "Theme (optional)",
                    placeholder: "e.g. Friendship, Courage, Survival",
                    text: $theme
                )
                
                OptionalField(
                                  label: "Place (optional)",
                                  placeholder: "e.g. A small village, a castle, Copenhagen",
                                  text: $place
                              )

                NewStoryButton(
                    title: "Start Story",
                    systemImage: "arrow.right.circle.fill",
                    trailingSparkle: false
                ) {
                    createStory()
                }
                .padding(.top, 6)

                Button("Skip") {
                    title = ""
                    genre = ""
                    theme = ""
                    place = ""
                    createStory()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.top, 2)
            }
            .padding(.top, 6)
        }
        .alert("Couldn’t create story", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private func createStory() {
        do {
            let repo = CoreDataChatRepository(ctx: ctx)

            let story = try repo.createStory(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                genre: genre.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                theme: theme.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                place: place.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
                language: settings.selectedLanguage
            )

            // IMPORTANT: Pop CreateStory first, then push Chat from the parent.
            dismiss()
            DispatchQueue.main.async {
                onStoryCreated(story)
            }
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

}

private struct OptionalField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                )
        }
    }
}
