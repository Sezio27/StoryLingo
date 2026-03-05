import Foundation
import CoreData
internal import Combine

@MainActor
final class StoriesListViewModel: ObservableObject {
    enum State: Equatable {
        case loading
        case empty
        case loaded
        case error(String)
    }

    @Published private(set) var state: State = .loading
    @Published private(set) var stories: [Story] = []
    @Published private(set) var errorMessage: String?

    private let repo: StoriesRepository
    private let ctx: NSManagedObjectContext
    private var saveObserver: NSObjectProtocol?

    private let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        return f
    }()

    init(repo: StoriesRepository, ctx: NSManagedObjectContext) {
        self.repo = repo
        self.ctx = ctx

        saveObserver = NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSave,
            object: ctx,
            queue: .main
        ) { [weak self] _ in
            Task { await self?.load() }
        }
    }

    deinit {
        if let saveObserver { NotificationCenter.default.removeObserver(saveObserver) }
    }

    func load() async {
        state = .loading
        do {
            let fetched = try repo.fetchStories()
            stories = fetched

            if fetched.isEmpty {
                state = .empty
            } else {
                state = .loaded
            }
        } catch {
            let msg = (error as NSError).localizedDescription
            errorMessage = msg
            state = .error(msg)
        }
    }

    func delete(_ story: Story) async {
        do {
            try repo.deleteStory(story)
            await load()
        } catch {
            let msg = (error as NSError).localizedDescription
            errorMessage = msg
            state = .error(msg)
        }
    }

    // MARK: - Row formatting helpers

    func titleText(for story: Story) -> String {
        let t = (story.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "New Story" : t
    }

    func relativeTimeText(for story: Story) -> String {
        let date = story.updatedAt ?? story.createdAt ?? Date()
        return relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    func messageCount(for story: Story) -> Int {
        // If you want max performance, cache this.
        // For now: compute on demand. (If it throws, show 0.)
        (try? repo.messageCount(for: story)) ?? 0
    }
}
