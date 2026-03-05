//
//  MainTabView.swift
//  StoryLingo
//
//  Created by Jakob Jacobsen on 12/02/2026.
//
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var ctx
    
    let settings: AppSettings

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(settings: settings)
            }
            .tabItem { Label("Home", systemImage: "house") }

            NavigationStack {
                StoriesListView(settings: settings, ctx: ctx)
            }
            .tabItem { Label("Stories", systemImage: "book") }

            NavigationStack {
                StatsView()
            }
            .tabItem { Label("Stats", systemImage: "chart.bar") }

            NavigationStack {
                SettingsView()
            }
            .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

