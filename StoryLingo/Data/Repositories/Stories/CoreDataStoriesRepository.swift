//
//  CoreDataStoriesRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import CoreData

final class CoreDataStoriesRepository: StoriesRepository {
    private let ctx: NSManagedObjectContext

    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
    }

    func fetchStories() throws -> [Story] {
        let req = Story.fetchRequest()
        req.sortDescriptors = [
            NSSortDescriptor(key: "updatedAt", ascending: false),
            NSSortDescriptor(key: "createdAt", ascending: false)
        ]
        return try ctx.fetch(req) as? [Story] ?? []
    }

    func messageCount(for story: Story) throws -> Int {
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        req.predicate = NSPredicate(format: "story == %@", story)
        return try ctx.count(for: req)
    }

    func deleteStory(_ story: Story) throws {
        ctx.delete(story)
        try ctx.save()
    }
}
