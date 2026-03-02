//
//  LanguageSeeder.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import CoreData

enum LanguageSeeder {
    static func seedIfNeeded(context: NSManagedObjectContext) {
        let req = NSFetchRequest<NSManagedObject>(entityName: "Language") // <- change if your entity is named "Langauge"
        req.fetchLimit = 1

        let hasAny = (try? context.count(for: req)) ?? 0 > 0
        guard !hasAny else { return }

        let seed: [(code: String, name: String, emoji: String)] = [
            ("da", "Danish", "🇩🇰"),
            ("de", "German", "🇩🇪"),
            ("es", "Spanish", "🇪🇸"),
            ("fr", "French", "🇫🇷"),
            ("it", "Italian", "🇮🇹"),
            ("ja", "Japanese", "🇯🇵"),
            ("ko", "Korean", "🇰🇷"),
            ("ro", "Romanian", "🇷🇴"),
            ("th", "Thai", "🇹🇭")
        ]


        for item in seed {
            let lang = Language(context: context) // <- change type if Xcode generated "Langauge"
            lang.code = item.code
            lang.displayName = item.name
            lang.flagEmoji = item.emoji
        }

        try? context.save()
    }
}
