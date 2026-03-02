//
//  MainTabView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//
import SwiftUI

struct MainTabView: View {
    let settings: AppSettings

    var body: some View {
        TabView {
            HomeView(settings: settings)
                .tabItem { Label("Home", systemImage: "house") }

            StoriesListView()
                .tabItem { Label("Stories", systemImage: "book") }

            StatsView()
                .tabItem { Label("Stats", systemImage: "chart.bar") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

