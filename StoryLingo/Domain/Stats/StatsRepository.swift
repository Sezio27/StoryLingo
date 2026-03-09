//
//  StatsRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 08/03/2026.
//

import Foundation
import CoreData

struct StatsSnapshot: Sendable {
    let uniqueWords: Int
    let practiceMinutes: Int
    let storiesCompleted: Int
    let totalMessages: Int
    let currentStreakDays: Int
}

protocol StatsRepository {
    func recordUserMessage(text: String, languageCode: String, at date: Date) throws
    func recordPractice(seconds: Int, at date: Date) throws
    func markStoryCompleted(_ story: Story, at date: Date) throws
    func fetchSnapshot(targetLanguageCode: String?) throws -> StatsSnapshot
}
