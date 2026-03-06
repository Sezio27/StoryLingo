//
//  OnboardingViewModel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation
import CoreData
internal import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var query = ""
    @Published var selectedTargetLanguage: Language?
    @Published var selectedNativeLanguage: Language?
    @Published var difficulty: DifficultyLevel = .intermediate

    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    private let languageRepository: LanguageRepositoryProtocol
    private let appSettingsRepository: AppSettingsRepositoryProtocol

    init(
        languageRepository: LanguageRepositoryProtocol = LanguageRepository(),
        appSettingsRepository: AppSettingsRepositoryProtocol = AppSettingsRepository()
    ) {
        self.languageRepository = languageRepository
        self.appSettingsRepository = appSettingsRepository
    }

    var canContinue: Bool {
        selectedTargetLanguage != nil && selectedNativeLanguage != nil && !isSaving
    }

    func filteredLanguages(from languages: [Language]) -> [Language] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return languages }

        return languages.filter { language in
            let name = language.displayName ?? ""
            let code = language.code ?? ""

            return name.localizedCaseInsensitiveContains(trimmed)
                || code.localizedCaseInsensitiveContains(trimmed)
        }
    }

    func load(context: NSManagedObjectContext) {
        errorMessage = nil

        do {
            let settings = try appSettingsRepository.fetchOrCreate(in: context)
            let languages = try languageRepository.fetchAll(in: context)
            let french = try languageRepository.fetchByCode("fr", in: context)
            let english = try languageRepository.fetchByCode("en", in: context)

            if selectedTargetLanguage == nil {
                selectedTargetLanguage = settings.selectedLanguage ?? french ?? languages.first
            }

            if selectedNativeLanguage == nil {
                selectedNativeLanguage = settings.nativeLanguage ?? english ?? languages.first
            }

            difficulty = DifficultyLevel(rawValue: settings.level) ?? .intermediate
        } catch {
            errorMessage = "Failed to load onboarding data."
        }
    }
    
    func completeOnboarding(context: NSManagedObjectContext) {
        guard let targetLanguage = selectedTargetLanguage,
              let nativeLanguage = selectedNativeLanguage else {
            return
        }

        errorMessage = nil
        isSaving = true
        defer { isSaving = false }

        do {
            try appSettingsRepository.completeOnboarding(
                targetLanguage: targetLanguage,
                nativeLanguage: nativeLanguage,
                difficulty: difficulty,
                in: context
            )
        } catch {
            errorMessage = "Failed to save onboarding."
        }
    }
}
