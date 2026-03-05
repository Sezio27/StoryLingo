//
//  ChatRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 02/03/2026.
//

import CoreData

protocol ChatRepository {
    func createStory(title: String?, genre: String?, theme: String?, language: Language?) throws -> Story
    func fetchMessages(for story: Story) throws -> [Message]
    func addMessage(text: String, isUser: Bool, to story: Story) throws -> Message
}
