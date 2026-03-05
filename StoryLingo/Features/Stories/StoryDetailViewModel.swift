import Foundation
import CoreData
internal import Combine

@MainActor
final class StoryDetailViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var story: Story
    @Published private(set) var messageCount: Int = 0
    @Published private(set) var errorMessage: String?


    private let repo: StoriesRepository
    private let ctx: NSManagedObjectContext
    private var saveObserver: NSObjectProtocol?

    // MARK: - Init

    init(story: Story, repo: StoriesRepository, ctx: NSManagedObjectContext) {
        self.story = story
        self.repo = repo
        self.ctx = ctx

        // Refresh when this context saves (e.g. new messages)
        saveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: ctx,
            queue: .main
        ) { [weak self] _ in
            Task { await self?.refreshStoryReferenceIfNeeded() ; await self?.load() }
        }
    }

    deinit {
        if let saveObserver { NotificationCenter.default.removeObserver(saveObserver) }
    }

    // MARK: - Derived UI text

    var titleText: String {
        let t = (story.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "New Story" : t
    }

    var createdExactText: String {
        let date = story.createdAt ?? Date()
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    var createdRelativeText: String {
        let date = story.createdAt ?? Date()
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }

    var updatedRelativeText: String {
        let date = story.updatedAt ?? story.createdAt ?? Date()
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f.localizedString(for: date, relativeTo: Date())
    }

    var genreText: String? {
        let t = (story.genre ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    var themeText: String? {
        let t = (story.theme ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }

    // MARK: - Actions

    func load() async {
        do {
            // story might be a fault; touching it is fine, but we refresh anyway below
            messageCount = try repo.messageCount(for: story)
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }

    func deleteStory() async {
        do {
            try repo.deleteStory(story)
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
    }
    
    func clearError() { errorMessage = nil }

    // MARK: - Helpers

    private func refreshStoryReferenceIfNeeded() async {
        // If the story got refreshed/updated/deleted, try to re-resolve it by objectID
        // (prevents stale faults issues in some navigation flows).
        do {
            if story.isDeleted { return }
            if let fresh = try ctx.existingObject(with: story.objectID) as? Story {
                story = fresh
            }
        } catch {
            // If it no longer exists, keep current; the view can decide what to do
        }
    }
}
