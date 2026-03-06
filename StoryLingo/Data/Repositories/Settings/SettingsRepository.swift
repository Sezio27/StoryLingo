import CoreData

protocol AppSettingsRepositoryProtocol {
    func fetchOrCreate(in context: NSManagedObjectContext) throws -> AppSettings
    func ensureDefaults(in context: NSManagedObjectContext) throws
    func completeOnboarding(
        targetLanguage: Language,
        nativeLanguage: Language,
        difficulty: DifficultyLevel,
        in context: NSManagedObjectContext
    ) throws

    func updateTargetLanguage(_ language: Language, in context: NSManagedObjectContext) throws
    func updateNativeLanguage(_ language: Language, in context: NSManagedObjectContext) throws
    func updateDifficulty(_ difficulty: DifficultyLevel, in context: NSManagedObjectContext) throws
}

struct AppSettingsRepository: AppSettingsRepositoryProtocol {
    private let languageRepository: LanguageRepositoryProtocol

    init(languageRepository: LanguageRepositoryProtocol = LanguageRepository()) {
        self.languageRepository = languageRepository
    }

    func fetchOrCreate(in context: NSManagedObjectContext) throws -> AppSettings {
        let req: NSFetchRequest<AppSettings> = AppSettings.fetchRequest()
        req.fetchLimit = 1

        if let existing = try context.fetch(req).first {
            return existing
        }

        let settings = AppSettings(context: context)
        settings.id = UUID()
        settings.createdAt = Date()
        settings.updatedAt = Date()
        settings.level = DifficultyLevel.intermediate.rawValue
        settings.hasCompletedOnboarding = false
        return settings
    }

    func ensureDefaults(in context: NSManagedObjectContext) throws {
        let settings = try fetchOrCreate(in: context)
        var didChange = false

        let firstLanguage = try languageRepository.fetchAll(in: context).first
        let french = try languageRepository.fetchByCode("fr", in: context)
        let english = try languageRepository.fetchByCode("en", in: context)

        if settings.selectedLanguage == nil {
            settings.selectedLanguage = french ?? firstLanguage
            didChange = true
        }

        if settings.nativeLanguage == nil {
            settings.nativeLanguage = english ?? firstLanguage
            didChange = true
        }

        if didChange {
            settings.updatedAt = Date()
            try context.save()
        }
    }

    func completeOnboarding(
        targetLanguage: Language,
        nativeLanguage: Language,
        difficulty: DifficultyLevel,
        in context: NSManagedObjectContext
    ) throws {
        let settings = try fetchOrCreate(in: context)
        settings.selectedLanguage = targetLanguage
        settings.nativeLanguage = nativeLanguage
        settings.level = difficulty.rawValue
        settings.hasCompletedOnboarding = true
        settings.updatedAt = Date()

        try context.save()
    }

    func updateTargetLanguage(_ language: Language, in context: NSManagedObjectContext) throws {
        let settings = try fetchOrCreate(in: context)
        settings.selectedLanguage = language
        settings.updatedAt = Date()
        try context.save()
    }

    func updateNativeLanguage(_ language: Language, in context: NSManagedObjectContext) throws {
        let settings = try fetchOrCreate(in: context)
        settings.nativeLanguage = language
        settings.updatedAt = Date()
        try context.save()
    }

    func updateDifficulty(_ difficulty: DifficultyLevel, in context: NSManagedObjectContext) throws {
        let settings = try fetchOrCreate(in: context)
        settings.level = difficulty.rawValue
        settings.updatedAt = Date()
        try context.save()
    }
}
