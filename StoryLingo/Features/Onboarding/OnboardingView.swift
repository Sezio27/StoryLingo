//
//  OnboardingView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI
import CoreData

struct OnboardingView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Language.displayName, ascending: true)],
        animation: .default
    )
    private var languages: FetchedResults<Language>

    @StateObject private var vm = OnboardingViewModel()

    @State private var isNativeExpanded = true
    @State private var isTargetExpanded = true

    private var filteredLanguages: [Language] {
        vm.filteredLanguages(from: Array(languages))
    }

    private var nativeLanguagesToShow: [Language] {
        if isNativeExpanded || vm.selectedNativeLanguage == nil {
            return filteredLanguages
        }
        return vm.selectedNativeLanguage.map { [$0] } ?? []
    }

    private var targetLanguagesToShow: [Language] {
        if isTargetExpanded || vm.selectedTargetLanguage == nil {
            return filteredLanguages
        }
        return vm.selectedTargetLanguage.map { [$0] } ?? []
    }

    var body: some View {
        PageScaffold(
            title: "Welcome",
            subtitle: "Pick your native language, target language and difficulty to start your first story."
        ) {
            ScrollView {
                VStack(spacing: 14) {

                    SettingsCard {
                        VStack(spacing: 0) {
                            SectionHeader("Choose your native language")

                            ForEach(nativeLanguagesToShow, id: \.objectID) { lang in
                                LanguageRow(
                                    flag: lang.flagEmoji ?? "🌍",
                                    name: lang.displayName ?? "—",
                                    code: (lang.code ?? "—").uppercased(),
                                    isSelected: lang.objectID == vm.selectedNativeLanguage?.objectID
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleNativeTap(lang)
                                }

                                if lang.objectID != nativeLanguagesToShow.last?.objectID {
                                    Divider().padding(.leading, 56)
                                }
                            }

                            if nativeLanguagesToShow.isEmpty {
                                EmptyLanguagesView()
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    SettingsCard {
                        VStack(spacing: 0) {
                            SectionHeader("Choose a target language")

                            ForEach(targetLanguagesToShow, id: \.objectID) { lang in
                                LanguageRow(
                                    flag: lang.flagEmoji ?? "🌍",
                                    name: lang.displayName ?? "—",
                                    code: (lang.code ?? "—").uppercased(),
                                    isSelected: lang.objectID == vm.selectedTargetLanguage?.objectID
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleTargetTap(lang)
                                }

                                if lang.objectID != targetLanguagesToShow.last?.objectID {
                                    Divider().padding(.leading, 56)
                                }
                            }

                            if targetLanguagesToShow.isEmpty {
                                EmptyLanguagesView()
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
                                isSelected: vm.difficulty == .beginner
                            ) {
                                vm.difficulty = .beginner
                            }

                            Divider().padding(.leading, 20)

                            DifficultyRow(
                                title: "Intermediate",
                                subtitle: "More natural dialogue",
                                isSelected: vm.difficulty == .intermediate
                            ) {
                                vm.difficulty = .intermediate
                            }

                            Divider().padding(.leading, 20)

                            DifficultyRow(
                                title: "Advanced",
                                subtitle: "Minimal help, more challenge",
                                isSelected: vm.difficulty == .advanced
                            ) {
                                vm.difficulty = .advanced
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    if let errorMessage = vm.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 4)
                    }

                    Spacer(minLength: 24)
                }
                .padding(.top, 6)
            }
            .searchable(text: $vm.query, prompt: "Search languages")
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()

                    Button {
                        vm.completeOnboarding(context: ctx)
                    } label: {
                        Group {
                            if vm.isSaving {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .frame(width: 54, height: 54)
                        .background(Circle().fill(Color.accentColor))
                        .shadow(color: .black.opacity(0.16), radius: 14, y: 10)
                    }
                    .buttonStyle(.plain)
                    .disabled(!vm.canContinue)
                    .opacity(vm.canContinue ? 1 : 0.45)

                    Spacer()
                }
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .onAppear {
                vm.load(context: ctx)
                isNativeExpanded = vm.selectedNativeLanguage == nil
                isTargetExpanded = vm.selectedTargetLanguage == nil
            }
        }
    }

    private func handleNativeTap(_ lang: Language) {
        if vm.selectedNativeLanguage?.objectID == lang.objectID {
            vm.selectedNativeLanguage = nil
            isNativeExpanded = true
        } else {
            vm.selectedNativeLanguage = lang
            isNativeExpanded = false
        }
    }

    private func handleTargetTap(_ lang: Language) {
        if vm.selectedTargetLanguage?.objectID == lang.objectID {
            vm.selectedTargetLanguage = nil
            isTargetExpanded = true
        } else {
            vm.selectedTargetLanguage = lang
            isTargetExpanded = false
        }
    }
}

private struct SectionHeader: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

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
            Text(flag)
                .font(.system(size: 22))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 17, weight: .semibold))

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
                Text(title)
                    .font(.system(size: 17, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 13))
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

private struct EmptyLanguagesView: View {
    var body: some View {
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
