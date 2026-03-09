import SwiftUI
import CoreData
internal import Combine

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var snapshot = StatsSnapshot(
        uniqueWords: 0,
        practiceMinutes: 0,
        storiesCompleted: 0,
        totalMessages: 0,
        currentStreakDays: 0
    )

    @Published var errorMessage: String?

    private let repo: StatsRepository
    private let ctx: NSManagedObjectContext

    init(repo: StatsRepository, ctx: NSManagedObjectContext) {
        self.repo = repo
        self.ctx = ctx
    }

    func load(targetLanguageCode: String?) {
        do {
            snapshot = try repo.fetchSnapshot(targetLanguageCode: targetLanguageCode)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
