//
//  StatsView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI
import CoreData

struct StatsView: View {
    @ObservedObject var settings: AppSettings
    private let ctx: NSManagedObjectContext
    @StateObject private var vm: StatsViewModel

    init(settings: AppSettings, ctx: NSManagedObjectContext) {
        self.settings = settings
        self.ctx = ctx
        _vm = StateObject(
            wrappedValue: StatsViewModel(
                repo: CoreDataStatsRepository(ctx: ctx),
                ctx: ctx
            )
        )
    }
    
    var body: some View {
        PageScaffold(
            title: "Statistics",
            subtitle: "Track your learning progress",
            scrolls: true
        ) {
            VStack(spacing: 16) {
                Text("Current Progress")

                HStack(spacing: 18) {
                    StatCardNumber(
                        icon: "sparkles",
                        title: "Unique Words",
                        amount: "\(vm.snapshot.uniqueWords)"
                    )

                    StatCardNumber(
                        icon: "sparkles",
                        title: "Practice Time",
                        amount: "\(vm.snapshot.practiceMinutes) min"
                    )
                }

                Text("Overall Statistics")

                StatsListCard(items: [
                    .init(icon: "target", iconTint: .green, iconBackground: .green.opacity(0.12), title: "Stories Completed", value: "\(vm.snapshot.storiesCompleted)"),
                    .init(icon: "bubble.left", iconTint: .gray, iconBackground: .orange.opacity(0.12),title: "Total Messages", value: "\(vm.snapshot.totalMessages)"),
                    .init(icon: "chart.line.uptrend.xyaxis", iconTint: .red, iconBackground: .blue.opacity(0.12), title: "Current Streak", value: "\(vm.snapshot.currentStreakDays) days")
                ])
    
            }
        }
        .onAppear {
                    vm.load(targetLanguageCode: settings.selectedLanguage?.code)
                }
                .onChange(of: settings.selectedLanguage?.code) { _, newCode in
                    vm.load(targetLanguageCode: newCode)
                }
    }
}
