//
//  LanguageSeeder.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import CoreData

enum LanguageSeeder {

    /// Seeds or updates the Language table (safe with unique constraint on `code`).
    static func seedOrUpdate(context: NSManagedObjectContext) {
        // Keep it fast and safe
        context.performAndWait {
            for item in LanguageCatalog.all {
                upsertLanguage(language: item, context: context)
            }

            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // If you still hit a conflict somehow, log it and continue in dev
                    let nsError = error as NSError
                    assertionFailure("LanguageSeeder failed to save: \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

    // MARK: - Private

    private static func upsertLanguage(language: LanguageDTO, context: NSManagedObjectContext) {
        // Fetch by unique key (code)
        let req: NSFetchRequest<Language> = Language.fetchRequest()
        req.predicate = NSPredicate(format: "code == %@", language.code)
        req.fetchLimit = 1

        let existing = (try? context.fetch(req))?.first

        let lang = existing ?? Language(context: context)

        // Ensure required fields are set
        lang.code = language.code
        lang.displayName = language.displayName
        lang.flagEmoji = language.flagEmoji
    }
}
