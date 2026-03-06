import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        entity: Language.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.displayName, ascending: true)]
    )
    private var languages: FetchedResults<Language>

    @StateObject private var vm = SettingsViewModel()

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    var body: some View {
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
                            title: "Native Language",
                            value: vm.nativeLanguage?.displayNameSafe ?? "—",
                            leadingValue: vm.nativeLanguage?.flagEmojiSafe
                        ) {
                            LanguagePickerView(
                                title: "Native Language",
                                languages: Array(languages),
                                selectedLanguage: vm.nativeLanguage
                            ) { language in
                                vm.setNativeLanguage(language, context: ctx)
                            }
                        }

                        SettingsNavigationCard(
                            title: "Target Language",
                            value: vm.targetLanguage?.displayNameSafe ?? "—",
                            leadingValue: vm.targetLanguage?.flagEmojiSafe
                        ) {
                            LanguagePickerView(
                                title: "Target Language",
                                languages: Array(languages),
                                selectedLanguage: vm.targetLanguage
                            ) { language in
                                vm.setTargetLanguage(language, context: ctx)
                            }
                        }

                        SettingsNavigationCard(
                            title: "Difficulty Level",
                            value: vm.difficulty.title
                        ) {
                            DifficultyPickerView(selection: vm.difficulty) { level in
                                vm.setDifficulty(level, context: ctx)
                            }
                        }
                    }

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
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
            .onAppear {
                vm.load(context: ctx)
            }
        }
    }
}
