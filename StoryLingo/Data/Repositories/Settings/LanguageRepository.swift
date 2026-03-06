//
//  LanguageRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 06/03/2026.
//

import CoreData

protocol LanguageRepositoryProtocol {
    func fetchAll(in context: NSManagedObjectContext) throws -> [Language]
    func fetchByCode(_ code: String, in context: NSManagedObjectContext) throws -> Language?
}

struct LanguageRepository: LanguageRepositoryProtocol {
    func fetchAll(in context: NSManagedObjectContext) throws -> [Language] {
        let req: NSFetchRequest<Language> = Language.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(keyPath: \Language.displayName, ascending: true)]
        return try context.fetch(req)
    }

    func fetchByCode(_ code: String, in context: NSManagedObjectContext) throws -> Language? {
        let req: NSFetchRequest<Language> = Language.fetchRequest()
        req.fetchLimit = 1
        req.predicate = NSPredicate(format: "code == %@", code)
        return try context.fetch(req).first
    }
}
