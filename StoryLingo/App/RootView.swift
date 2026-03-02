import SwiftUI
import CoreData

struct RootView: View {
    @Environment(\.managedObjectContext) private var ctx

    @FetchRequest(sortDescriptors: [], animation: .default)
    private var settingsResults: FetchedResults<AppSettings>

    var body: some View {
        Group {
            if let s = settingsResults.first {
                RootSwitch(settings: s)
            } else {
                OnboardingView()
            }
        }
        .task {
            await ctx.perform {
                PersistenceBootstrap.run(in: ctx)
                ctx.saveIfNeeded()
            }
        }
    }
}

private struct RootSwitch: View {
    @ObservedObject var settings: AppSettings

    var body: some View {
        if settings.hasCompletedOnboarding {
            MainTabView(settings: settings)
        } else {
            OnboardingView()
        }
    }
}
