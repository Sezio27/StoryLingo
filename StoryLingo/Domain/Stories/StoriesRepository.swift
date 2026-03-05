//
//  StoriesRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 05/03/2026.
//

import CoreData

protocol StoriesRepository {
    func fetchStories() throws -> [Story]
    func messageCount(for story: Story) throws -> Int
    func deleteStory(_ story: Story) throws
}
