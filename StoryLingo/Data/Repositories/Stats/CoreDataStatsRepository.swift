//
//  CoreDataStatsRepository.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 08/03/2026.
//

import CoreData

final class CoreDataStatsRepository: StatsRepository {
    private let ctx: NSManagedObjectContext
    private let calendar: Calendar

    init(ctx: NSManagedObjectContext, calendar: Calendar = .current) {
        self.ctx = ctx
        self.calendar = calendar
    }

    func recordUserMessage(text: String, languageCode: String, at date: Date = Date()) throws {
        let words = text.normalizedWords()

        for word in words {
            let request = NSFetchRequest<KnownWord>(entityName: "KnownWord")
            request.fetchLimit = 1
            request.predicate = NSPredicate(
                format: "normalized == %@ AND languageCode == %@",
                word,
                languageCode
            )

            let exists = try ctx.count(for: request) > 0
            if !exists {
                let known = KnownWord(context: ctx)
                known.normalized = word
                known.languageCode = languageCode
                known.firstSeenAt = date
            }
        }

        if ctx.hasChanges {
            try ctx.save()
        }
    }

    func recordPractice(seconds: Int, at date: Date = Date()) throws {
        guard seconds > 0 else { return }

        let day = calendar.startOfDay(for: date)
        let stat = try fetchOrCreateDailyStats(for: day)
        stat.minutesPracticed += Double(seconds) / 60.0
        stat.sessionsCount += 1
        try ctx.save()
    }

    func markStoryCompleted(_ story: Story, at date: Date = Date()) throws {
        if story.completedAt == nil {
            story.completedAt = date
            story.updatedAt = date
            try ctx.save()
        }
    }

    func fetchSnapshot(targetLanguageCode: String?) throws -> StatsSnapshot {
        let uniqueWords = try uniqueWordCount(languageCode: targetLanguageCode)
        let practiceMinutes = Int(try totalPracticeMinutes().rounded())
        let storiesCompleted = try completedStoriesCount()
        let totalMessages = try messageCount()
        let currentStreakDays = try streakDays()

        return StatsSnapshot(
            uniqueWords: uniqueWords,
            practiceMinutes: practiceMinutes,
            storiesCompleted: storiesCompleted,
            totalMessages: totalMessages,
            currentStreakDays: currentStreakDays
        )
    }

    private func fetchOrCreateDailyStats(for day: Date) throws -> Stats {
        let request = NSFetchRequest<Stats>(entityName: "Stats")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "date == %@", day as NSDate)

        if let existing = try ctx.fetch(request).first {
            return existing
        }

        let stats = Stats(context: ctx)
        stats.date = day
        stats.minutesPracticed = 0
        stats.sessionsCount = 0
        stats.uniqueWords = 0
        return stats
    }

    private func uniqueWordCount(languageCode: String?) throws -> Int {
        let request = NSFetchRequest<KnownWord>(entityName: "KnownWord")
        if let languageCode {
            request.predicate = NSPredicate(format: "languageCode == %@", languageCode)
        }
        return try ctx.count(for: request)
    }

    private func totalPracticeMinutes() throws -> Double {
        let request = NSFetchRequest<NSDictionary>(entityName: "Stats")
        let expression = NSExpressionDescription()
        expression.name = "sumMinutes"
        expression.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "minutesPracticed")])
        expression.expressionResultType = .doubleAttributeType
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [expression]

        let result = try ctx.fetch(request).first
        return result?["sumMinutes"] as? Double ?? 0
    }

    private func completedStoriesCount() throws -> Int {
        let request = NSFetchRequest<Story>(entityName: "Story")
        request.predicate = NSPredicate(format: "completedAt != nil")
        return try ctx.count(for: request)
    }

    private func messageCount() throws -> Int {
        let request = NSFetchRequest<Message>(entityName: "Message")
        return try ctx.count(for: request)
    }

    private func streakDays() throws -> Int {
        let request = NSFetchRequest<Message>(entityName: "Message")
        request.predicate = NSPredicate(format: "isUser == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

        let messages = try ctx.fetch(request)

        let activeDays = Set(messages.compactMap { message in
            message.timestamp.map { calendar.startOfDay(for: $0) }
        })

        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while activeDays.contains(day) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }

        return streak
    }
}
