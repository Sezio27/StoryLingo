//
//  SettingsViewModel.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import Foundation
import CoreData
internal import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var targetLanguage: Language?
    @Published private(set) var nativeLanguage: Language?
    @Published private(set) var difficulty: DifficultyLevel = .intermediate
    @Published private(set) var errorMessage: String?

    private let languageRepository: LanguageRepositoryProtocol
    private let settingsRepository: AppSettingsRepositoryProtocol

    init(
        languageRepository: LanguageRepositoryProtocol = LanguageRepository(),
        settingsRepository: AppSettingsRepositoryProtocol = AppSettingsRepository()
    ) {
        self.languageRepository = languageRepository
        self.settingsRepository = settingsRepository
    }

    func load(context: NSManagedObjectContext) {
        errorMessage = nil

        do {
            let settings = try settingsRepository.fetchOrCreate(in: context)
            let languages = try languageRepository.fetchAll(in: context)
            let fallbackLanguage = languages.first

            targetLanguage = settings.selectedLanguage ?? fallbackLanguage
            nativeLanguage = settings.nativeLanguage ?? fallbackLanguage
            difficulty = DifficultyLevel(rawValue: settings.level) ?? .intermediate
        } catch {
            errorMessage = "Failed to load settings."
        }
    }

    func setTargetLanguage(_ language: Language, context: NSManagedObjectContext) {
        errorMessage = nil

        do {
            try settingsRepository.updateTargetLanguage(language, in: context)
            targetLanguage = language
        } catch {
            errorMessage = "Failed to update target language."
        }
    }

    func setNativeLanguage(_ language: Language, context: NSManagedObjectContext) {
        errorMessage = nil

        do {
            try settingsRepository.updateNativeLanguage(language, in: context)
            nativeLanguage = language
        } catch {
            errorMessage = "Failed to update native language."
        }
    }

    func setDifficulty(_ newDifficulty: DifficultyLevel, context: NSManagedObjectContext) {
        errorMessage = nil

        do {
            try settingsRepository.updateDifficulty(newDifficulty, in: context)
            difficulty = newDifficulty
        } catch {
            errorMessage = "Failed to update difficulty."
        }
    }
}
