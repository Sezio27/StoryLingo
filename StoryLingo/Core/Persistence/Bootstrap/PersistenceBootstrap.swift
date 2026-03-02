//
//  PersistenceBootstrap.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import CoreData

enum PersistenceBootstrap {

    struct LanguageSeed {
        let code: String
        let name: String
        let flag: String
    }

    static let defaultLanguages: [LanguageSeed] = [
        .init(code: "fr", name: "French",  flag: "🇫🇷"),
        .init(code: "es", name: "Spanish", flag: "🇪🇸"),
        .init(code: "de", name: "German",  flag: "🇩🇪"),
        .init(code: "it", name: "Italian", flag: "🇮🇹"),
        .init(code: "da", name: "Danish",  flag: "🇩🇰"),
    ]

    static func run(in ctx: NSManagedObjectContext) {
        seedLanguagesIfNeeded(in: ctx)
        ensureAppSettings(in: ctx)
        ctx.saveIfNeeded()
    }

    private static func seedLanguagesIfNeeded(in ctx: NSManagedObjectContext) {
        let req = Language.fetchRequest()
        req.fetchLimit = 1

        let hasAny = (try? ctx.count(for: req)) ?? 0 > 0
        guard !hasAny else { return }

        for s in defaultLanguages {
            let lang = Language(context: ctx)
            lang.code = s.code
            lang.displayName = s.name
            lang.flagEmoji = s.flag
        }
    }

    private static func ensureAppSettings(in ctx: NSManagedObjectContext) {
        let req = AppSettings.fetchRequest()
        req.fetchLimit = 1

        let settings: AppSettings
        if let existing = (try? ctx.fetch(req))?.first {
            settings = existing
        } else {
            let s = AppSettings(context: ctx)
            s.id = UUID()
            s.createdAt = Date()
            s.updatedAt = Date()
            s.level = DifficultyLevel.intermediate.rawValue
            settings = s
        }

        // Ensure selectedLanguage is set
        if settings.selectedLanguage == nil {
            let langReq = Language.fetchRequest()
            langReq.fetchLimit = 1
            langReq.predicate = NSPredicate(format: "code == %@", "fr")

            let fallback = (try? ctx.fetch(langReq))?.first
                ?? (try? ctx.fetch(Language.fetchRequest()))?.first

            settings.selectedLanguage = fallback
            settings.updatedAt = Date()
        }
    }
}
