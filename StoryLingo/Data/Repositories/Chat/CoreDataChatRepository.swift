//
//  CoreDataChatRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import CoreData

final class CoreDataChatRepository: ChatRepository {
    private let ctx: NSManagedObjectContext

    init(ctx: NSManagedObjectContext) {
        self.ctx = ctx
    }

    func createStory(title: String?, language: Language?) throws -> Story {
        guard let language else {
            throw NSError(domain: "Chat", code: 2, userInfo: [NSLocalizedDescriptionKey: "Missing language"])
        }

        let story = Story(context: ctx)
        story.id = UUID()
        story.title = (title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false) ? title : "New Story"
        story.createdAt = Date()
        story.updatedAt = Date()

        story.language = language


        try ctx.save()
        return story
    }

    func fetchMessages(for story: Story) throws -> [Message] {
        let req = Message.fetchRequest()
        req.predicate = NSPredicate(format: "story == %@", story)
        req.sortDescriptors = [
            NSSortDescriptor(key: "timestamp", ascending: true)
        ]
        return try ctx.fetch(req) as? [Message] ?? []
    }

    func addMessage(text: String, isUser: Bool, to story: Story) throws -> Message {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw NSError(domain: "Chat", code: 1) }

        let msg = Message(context: ctx)
        msg.id = UUID()
        msg.text = trimmed
        msg.isUser = isUser
        msg.timestamp = Date()
        msg.story = story

        story.updatedAt = Date()

        try ctx.save()
        return msg
    }
}
