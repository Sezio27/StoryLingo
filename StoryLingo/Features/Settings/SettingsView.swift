import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        entity: AppSettings.entity(),
        sortDescriptors: []
    ) private var settingsResults: FetchedResults<AppSettings>

    @FetchRequest(
        entity: Language.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.displayName, ascending: true)]
    ) private var languages: FetchedResults<Language>

    private var settings: AppSettings {
        // Assumes bootstrap ensured it exists.
        settingsResults.first!
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    private var selectedLanguage: Binding<Language> {
        Binding(
            get: { settings.selectedLanguage ?? languages.first! },
            set: { newLang in
                settings.selectedLanguage = newLang
                settings.updatedAt = Date()
                ctx.saveIfNeeded()
            }
        )
    }

    private var difficulty: Binding<DifficultyLevel> {
        Binding(
            get: { settings.difficulty },
            set: { newLevel in
                settings.difficulty = newLevel
                settings.updatedAt = Date()
                ctx.saveIfNeeded()
            }
        )
    }

    var body: some View {
        let lang = settings.selectedLanguage ?? languages.first

        PageScaffold(
            title: "Settings",
            subtitle: "Customize your learning experience"
        ) {
            ScrollView {
                VStack(spacing: 12) {
                    Text("Learning")
                        .font(.system(size: 26, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 14) {
                        SettingsNavigationCard(
                            title: "Target Language",
                            value: lang?.displayNameSafe ?? "—",
                            leadingValue: lang?.flagEmojiSafe
                        ) {
                            LanguagePickerView(
                                languages: Array(languages),
                                selection: selectedLanguage
                            )
                        }

                        SettingsNavigationCard(
                            title: "Difficulty Level",
                            value: difficulty.wrappedValue.title
                        ) {
                            DifficultyPickerView(selection: difficulty)
                        }
                    }

                    Text("About")
                        .font(.system(size: 26, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    SettingsTableCard(rows: [
                        ("Version", appVersion),
                        ("Build", appBuild),
                    ])
                }
            }
        }
    }
}
