//
//  RootView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//

import SwiftUI
import CoreData

struct RootView: View {
    @FetchRequest(
        sortDescriptors: [],
        animation: .default
    ) private var settings: FetchedResults<AppSettings>

    var body: some View {
        Group {
            if let settings = settings.first {
                MainTabView(settings: settings)
            } else {
                OnboardingView()
            }
        }
    }
}
