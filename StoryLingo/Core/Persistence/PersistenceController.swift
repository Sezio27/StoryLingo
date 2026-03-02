//
//  Persistence.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let context = result.container.viewContext

        // --- Seed Languages (adjust attribute names if needed) ---
        let es = Language(context: context)
        es.code = "es"
        es.displayName = "Spanish"
        es.flagEmoji = "🇪🇸"

        let de = Language(context: context)
        de.code = "de"
        de.displayName = "German"
        de.flagEmoji = "🇩🇪"

        // --- Create AppSettings pointing to a Language ---
        let settings = AppSettings(context: context)
        settings.id = UUID()
        settings.level = 1
        settings.createdAt = Date()
        settings.updatedAt = Date()
        settings.selectedLanguage = es

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "StoryLingo")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
