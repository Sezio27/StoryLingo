import SwiftUI
import CoreData

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var settingsResults: FetchedResults<AppSettings>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.displayName, ascending: true)],
        animation: .default
    ) private var languages: FetchedResults<Language>

    @State private var query = ""
    @State private var selectedLanguage: Language?
    @State private var difficulty: DifficultyLevel = .intermediate

    private var filteredLanguages: [Language] {
        let all = Array(languages)
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return all }

        return all.filter {
            ($0.displayName ?? "").localizedCaseInsensitiveContains(q) ||
            ($0.code ?? "").localizedCaseInsensitiveContains(q)
        }
    }

    var body: some View {
        PageScaffold(
            title: "Welcome",
            subtitle: "Pick a language and difficulty to start your first story."
        ) {
            ScrollView {
                VStack(spacing: 14) {
                    

                    SettingsCard {
                        VStack(spacing: 0) {
                            SectionHeader("Choose a language")

                            ForEach(filteredLanguages, id: \.objectID) { lang in
                                LanguageRow(
                                    flag: lang.flagEmoji ?? "🌍",
                                    name: lang.displayName ?? "—",
                                    code: (lang.code ?? "—").uppercased(),
                                    isSelected: lang.objectID == selectedLanguage?.objectID
                                )
                                .contentShape(Rectangle())
                                .onTapGesture { selectedLanguage = lang }

                                if lang.objectID != filteredLanguages.last?.objectID {
                                    Divider().padding(.leading, 56)
                                }
                            }

                            if filteredLanguages.isEmpty {
                                VStack(spacing: 8) {
                                    Text("No languages found")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Try a different search.")
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    SettingsCard {
                        VStack(spacing: 0) {
                            SectionHeader("Difficulty")

                            DifficultyRow(
                                title: "Beginner",
                                subtitle: "Short sentences, lots of help",
                                isSelected: difficulty == .beginner
                            ) { difficulty = .beginner }

                            Divider().padding(.leading, 20)

                            DifficultyRow(
                                title: "Intermediate",
                                subtitle: "More natural dialogue",
                                isSelected: difficulty == .intermediate
                            ) { difficulty = .intermediate }

                            Divider().padding(.leading, 20)

                            DifficultyRow(
                                title: "Advanced",
                                subtitle: "Minimal help, more challenge",
                                isSelected: difficulty == .advanced
                            ) { difficulty = .advanced }
                        }
                        .padding(.vertical, 8)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 6)
            }
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()

                    Button {
                        completeOnboarding()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 54, height: 54)
                            .background(Circle().fill(Color.accentColor))
                            .shadow(color: .black.opacity(0.16), radius: 14, y: 10)
                    }
                    .buttonStyle(.plain)
                    .disabled(selectedLanguage == nil || settingsResults.first == nil)
                    .opacity((selectedLanguage == nil || settingsResults.first == nil) ? 0.45 : 1)

                    Spacer()
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                // Reasonable defaults when the screen opens
                if selectedLanguage == nil {
                    selectedLanguage = settingsResults.first?.selectedLanguage ?? languages.first
                }
                if let s = settingsResults.first {
                    difficulty = DifficultyLevel(rawValue: s.level) ?? .intermediate
                }
            }
        }
    }

    private func completeOnboarding() {
        guard let lang = selectedLanguage else { return }
        guard let s = settingsResults.first else { return }

        s.selectedLanguage = lang
        s.level = difficulty.rawValue
        s.hasCompletedOnboarding = true
        s.updatedAt = Date()

        ctx.saveIfNeeded()
    }
}

private struct SectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
    }
}

private struct LanguageRow: View {
    let flag: String
    let name: String
    let code: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(flag).font(.system(size: 22))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(name).font(.system(size: 17, weight: .semibold))
                Text(code)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.tint)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

private struct DifficultyRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 17, weight: .semibold))
                Text(subtitle).font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundStyle(.tint)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
