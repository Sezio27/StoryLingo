//
//  ChatRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import CoreData

protocol ChatRepository {
    func createStory(title: String?, genre: String?, theme: String?, place: String?, language: Language?) throws -> Story
    func fetchMessages(for story: Story) throws -> [Message]
    func addMessage(text: String, isUser: Bool, to story: Story) throws -> Message
    func saveTranslation(_ translation: BubbleTranslation, for message: Message) throws
}
