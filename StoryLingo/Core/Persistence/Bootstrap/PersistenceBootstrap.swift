import CoreData

enum PersistenceBootstrap {
    static func run(in ctx: NSManagedObjectContext) {
        LanguageSeeder.seedOrUpdate(context: ctx)

        let settingsRepository = AppSettingsRepository()
        do {
            try settingsRepository.ensureDefaults(in: ctx)
        } catch {
            let nsError = error as NSError
            assertionFailure("PersistenceBootstrap failed: \(nsError), \(nsError.userInfo)")
        }

        ctx.saveIfNeeded()
    }
}
