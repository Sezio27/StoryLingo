//
//  NSManagedObjectContext+Save.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import CoreData

extension NSManagedObjectContext {
    func saveIfNeeded() {
        guard hasChanges else { return }
        do { try save() }
        catch { assertionFailure("Core Data save failed: \(error)") }
    }
}
